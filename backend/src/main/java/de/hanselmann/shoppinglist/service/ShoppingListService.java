package de.hanselmann.shoppinglist.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.lang.Nullable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionException;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListCategory;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.model.ShoppingListPermission;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.repository.ShoppingListCategoriesRepository;
import de.hanselmann.shoppinglist.repository.ShoppingListItemsRepository;
import de.hanselmann.shoppinglist.repository.ShoppingListPermissionsRepository;
import de.hanselmann.shoppinglist.repository.ShoppingListRepository;

@Service
public class ShoppingListService {
    private final ShoppingListRepository listsRepository;
    private final ShoppingListPermissionsRepository permissionsRepository;
    private final ShoppingListItemsRepository itemsRepository;
    private final ShoppingListCategoriesRepository categoriesRepository;
    private final ShoppingListUserService userService;
    /**
     * The @Transaction annotation only works on public methods that are called by
     * another bean. In all other locations we need the transaction template.
     */
    private final TransactionTemplate transactionTemplate;

    @Autowired
    public ShoppingListService(ShoppingListRepository listsRepository,
            ShoppingListUserService userService,
            ShoppingListPermissionsRepository permissionsRepository,
            ShoppingListItemsRepository itemsRepository,
            ShoppingListCategoriesRepository categoriesRepository,
            PlatformTransactionManager transactionManager) {
        this.listsRepository = listsRepository;
        this.userService = userService;
        this.permissionsRepository = permissionsRepository;
        this.itemsRepository = itemsRepository;
        this.categoriesRepository = categoriesRepository;
        transactionTemplate = new TransactionTemplate(transactionManager);
    }

    public @Nullable ShoppingList createShoppingListForCurrentUser(String name) {
        if (name == null || name.isBlank()) {
            return null;
        }
        try {
            return transactionTemplate.execute(status -> createShoppingListForCurrentUserImpl(name));
        } catch (TransactionException | DataIntegrityViolationException e) {
            return null;
        }
    }

    private ShoppingList createShoppingListForCurrentUserImpl(String name) {
        final var currentTime = LocalDateTime.now();
        final ShoppingListUser user = userService.getCurrentUser();
        var shoppingList = new ShoppingList(name, user, currentTime);
        var permission = new ShoppingListPermission(ShoppingListRole.ADMIN, user, shoppingList, currentTime);
        shoppingList.addPermission(permission);
        user.addPermission(permission);
        listsRepository.save(shoppingList);
        permissionsRepository.save(permission);
        return shoppingList;
    }

    public boolean addUserToShoppingList(long shoppingListId, ShoppingListUser user) {
        if (user.getShoppingListPermissions().stream()
                .anyMatch(permission -> permission.getList().getId() == shoppingListId)) {
            return false;
        }

        return listsRepository.findById(shoppingListId).map(list -> {
            addUserToShoppingList(list, user);
            return true;
        }).orElse(false);
    }

    public void addUserToShoppingList(ShoppingList list, ShoppingListUser user) {
        var permission = new ShoppingListPermission(ShoppingListRole.READ_WRITE, user, list, LocalDateTime.now());
        permission = permissionsRepository.save(permission);
        user.addPermission(permission);
    }

    public Stream<ShoppingList> getShoppingListsOfCurrentUser() {
        return userService.getCurrentUser().getShoppingListPermissions().stream().map(ShoppingListPermission::getList);
    }

    public ShoppingListItem createNewItem(String name, @Nullable String category, ShoppingList list) {
        var newItem = new ShoppingListItem(name, list);
        newItem.setCategory(getOrCreateCategory(category, list));
        newItem.setPosition(list.getItems().size());
        itemsRepository.save(newItem);
        return newItem;
    }

    private ShoppingListCategory getOrCreateCategory(String name, ShoppingList list) {
        if (name == null) {
            return null;
        }
        return transactionTemplate.execute(status -> categoriesRepository.findByNameAndList(name, list)
                .orElseGet(() -> categoriesRepository.save(new ShoppingListCategory(name, list))));
    }

    public Optional<ShoppingList> findShoppingList(long id) {
        return listsRepository.findById(id);
    }

    public void deleteOrLeaveShoppingListsOfUser(ShoppingListUser user) {
        user.getShoppingListPermissions().forEach(this::removeShoppingListPermission);
    }

    public void removeUserFromShoppingList(Long shoppingListId, Long userId) {
        findShoppingList(shoppingListId).ifPresent(list -> removeUserFromShoppingList(list, userId));
    }

    private void removeUserFromShoppingList(ShoppingList list, Long userId) {
        list.getPermissionOfUser(userId).ifPresent(this::removeShoppingListPermission);
    }

    private void removeShoppingListPermission(ShoppingListPermission permission) {
        if (!isCurrentUserAllowedToRemovePermission(permission)) {
            throw new AccessDeniedException("Current user is not allowed to delete the user from the list.");
        }

        boolean containsOtherAdmins = permission.getList().getPermissions().stream()
                .filter(p -> p != permission)
                .anyMatch(p -> p.getRole() == ShoppingListRole.ADMIN);

        transactionTemplate.executeWithoutResult(status -> {
            permissionsRepository.delete(permission);
            if (!containsOtherAdmins) {
                // deleted user was the last ADMIN of the list => delete the list
                listsRepository.delete(permission.getList());
            }
        });
    }

    private boolean isCurrentUserAllowedToRemovePermission(ShoppingListPermission permission) {
        ShoppingListUser currentUser = userService.getCurrentUser();
        if (Objects.equals(permission.getUser().getId(), currentUser.getId())) {
            return true; // you can always remove yourself from a list
        }
        if (currentUser.isSuperUser() && !permission.getUser().isSuperUser()) {
            return true; // a user can remove another non-super user from a list
        }
        if (permission.getRole() == ShoppingListRole.ADMIN) {
            return false; // admins can only remove them self or be removed by an admin user
        }
        return permission.getList().getPermissionOfUser(currentUser)
                .filter(p -> p.getRole().canDeleteUsers())
                .isPresent();
    }

    /**
     * Uncheck items of list.<br>
     * All items, if category is null, only items with matching category otherwise.
     *
     * @param list     ShoppingList
     * @param category Items with this category will be unchecked. If null, all
     *                 items will be unchecked.
     */
    public void uncheckItems(ShoppingList list, @Nullable String category) {
        List<ShoppingListItem> itemsToUncheck = list.getItems().stream()
                .filter(ShoppingListItem::isChecked)
                .filter(item -> category == null || category.equals(item.getCategory().getName()))
                .collect(Collectors.toList());
        itemsToUncheck.forEach(item -> item.setChecked(false));
        itemsRepository.saveAll(itemsToUncheck);
    }

    /**
     * Remove categories of list.<br>
     * All categories, if category is null, only given category otherwise.
     *
     * @param list         ShoppingList
     * @param categoryName The category with this name will be removed. If null, all
     *                     categories will be removed.
     */
    @Transactional
    public void removeCategory(long listId, @Nullable String categoryName) {
        if (categoryName == null) {
            itemsRepository.findByListId(listId).forEach(ShoppingListItem::removeFromCategory);
            categoriesRepository.deleteByListId(listId);
        } else {
            categoriesRepository.findByNameAndListId(categoryName, listId).ifPresent(category -> {
                itemsRepository.findByListIdAndCategory(listId, category).forEach(ShoppingListItem::removeFromCategory);
                categoriesRepository.delete(category);
            });
        }
    }

    public void renameCategory(long listId, String oldCategory, String newCategory) {
        categoriesRepository.findByNameAndListId(oldCategory, listId)
                .ifPresent(category -> renameCategory(listId, category, newCategory));
    }

    private void renameCategory(long listId, ShoppingListCategory category, String newName) {
        ShoppingListCategory newCategory = categoriesRepository.findByNameAndListId(newName, listId).orElse(null);
        if (newCategory == null) {
            // No category with the new name exists in this list... just rename the category
            category.setName(newName);
            categoriesRepository.save(category);
            return;
        }

        // A category with the new name is already present... we can not have two
        // categories with the same name.
        // Reassign all items of the old category to the already present category and
        // delete the old category.
        transactionTemplate.executeWithoutResult(action -> {
            itemsRepository.findByListIdAndCategory(listId, category).forEach(item -> item.setCategory(newCategory));
            categoriesRepository.delete(category);
        });
    }

    @Transactional
    public void deleteAllItems(long listId) {
        itemsRepository.deleteByListId(listId);
    }

    @Transactional
    public void deleteItemWithId(long listId, long itemId) {
        // the list id must be part of the query otherwise a user
        // can delete items in lists to which he has no access
        itemsRepository.deleteByIdAndListId(itemId, listId);
    }

    @Transactional
    public boolean moveShoppingListItem(long listId, long itemId, int targetIndex) {
        if (targetIndex < 0) {
            return false;
        }
        // the list id must be part of the query otherwise a user
        // can move items in lists to which he has no access
        ShoppingListItem item = itemsRepository.findByIdAndListId(itemId, listId).orElse(null);
        if (item == null) {
            return false;
        }
        ShoppingList list = item.getList();

        final int oldPosition = item.getPosition();
        final int newPosition = Math.min(targetIndex, list.getItems().size() - 1);
        list.getItems().forEach(current -> {
            if (current.getId().equals(item.getId())) {
                // current item is the item that we want to move
                item.setPosition(newPosition);
            } else if (oldPosition > newPosition
                    && current.getPosition() < oldPosition
                    && current.getPosition() >= newPosition) {
                // The item is moved towards the start of the list.
                // Increase the position of all items that are
                // between the moved items new (inclusive) and old position (exclusive).
                // 0| 1| 2| 3| 4
                // a| b| c| d| e : move(d, 1)
                // a| b| c| e| _ : remove(d)
                // a| d| b| c| e : insert(d, 1)
                current.setPosition(current.getPosition() + 1);
            } else if (oldPosition < newPosition
                    && current.getPosition() > oldPosition
                    && current.getPosition() <= newPosition) {
                // The item is moved towards the start of the list.
                // Increase the position of all items that are
                // between the moved items old (exclusive) and new position (inclusive).
                // 0| 1| 2| 3| 4
                // a| b| c| d| e : move(b, 3)
                // a| c| d| e| _ : remove(b)
                // a| c| d| b| e : insert(b, 3)
                current.setPosition(current.getPosition() - 1);
            }
        });
        return true;
    }

    public void renameList(long shoppingListId, String name) {
        ShoppingList list = findShoppingList(shoppingListId).orElseThrow();
        list.setName(name);
        listsRepository.save(list);
    }

    public void updateItem(long itemId, String name, boolean checked, String category) {
        itemsRepository.findById(itemId).ifPresent(item -> {
            boolean nameChanged = Objects.equals(name, item.getName());
            boolean categoryChanged = Objects.equals(category, item.getCategoryName());
            boolean checkedStateChanged = Objects.equals(checked, item.isChecked());

            ShoppingListPermission userPermissions = item.getList().getPermissionOfUser(userService.getCurrentUser())
                    .get();

            if ((nameChanged || categoryChanged) && !userPermissions.getRole().canEditItems()) {
                throw new AccessDeniedException("User is not allowed to edit the item.");
            }
            if (checkedStateChanged && !userPermissions.getRole().canCheckItems()) {
                throw new AccessDeniedException("User is not allowed to check or uncheck the item.");
            }

            item.setName(name);
            item.setChecked(checked);
            item.setCategory(getOrCreateCategory(category, item.getList()));
            item.setPosition(item.getPosition());
            itemsRepository.save(item);
        });
    }
}
