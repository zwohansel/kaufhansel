package de.hanselmann.shoppinglist.service;

import de.hanselmann.shoppinglist.model.*;
import de.hanselmann.shoppinglist.repository.ShoppingListCategoriesRepository;
import de.hanselmann.shoppinglist.repository.ShoppingListItemsRepository;
import de.hanselmann.shoppinglist.repository.ShoppingListPermissionsRepository;
import de.hanselmann.shoppinglist.repository.ShoppingListRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.lang.Nullable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionException;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Service
public class ShoppingListService {
    private final ShoppingListRepository listsRepository;
    private final ShoppingListPermissionsRepository permissionsRepository;
    private final ShoppingListItemsRepository itemsRepository;
    private final ShoppingListCategoriesRepository categoriesRepository;
    private final ShoppingListUserService userService;
    /**
     * The @Transaction annotation only works on public methods that are called by another bean.
     * In all other locations we need the transaction template.
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

    public @Nullable
    ShoppingList createShoppingListForCurrentUser(String name) {
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
        final var permission = new ShoppingListPermission(ShoppingListRole.READ_WRITE, user, list, LocalDateTime.now());
        permissionsRepository.save(permission);
    }

    public Stream<ShoppingList> getShoppingListsOfCurrentUser() {
        return userService.getCurrentUser().getShoppingListPermissions().stream().map(ShoppingListPermission::getList);
    }

    public ShoppingListItem createNewItem(String name, @Nullable String category, ShoppingList list) {
        var newItem = new ShoppingListItem(name, list);
        newItem.setCategory(getOrCreateCategory(category, list));
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
        user.getShoppingListPermissions()
                .forEach(permission -> removeUserFromList(permission.getList().getId(), user));
    }

    public boolean removeUserFromList(long listId, ShoppingListUser user) {
        try {
            transactionTemplate.executeWithoutResult(status -> tryRemoveCurrentUserFromShoppingList(listId, user));
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    void tryRemoveCurrentUserFromShoppingList(long listId, ShoppingListUser user) {
        ShoppingList list = findShoppingList(listId).orElseThrow();
        ShoppingListPermission currentUserPermission = list.getPermissionOfUser(user).orElseThrow();

        boolean containsOtherAdmins = list.getPermissions().stream()
                .filter(permission -> permission != currentUserPermission)
                .anyMatch(permission -> permission.getRole() == ShoppingListRole.ADMIN);
        if (containsOtherAdmins) {
            permissionsRepository.delete(currentUserPermission);
        } else {
            // Current user is the last ADMIN of the list => delete the list
            listsRepository.delete(list);
        }
    }

    public void removeUserFromShoppingList(long shoppingListId, long userId) {
        ShoppingListUser userToBeRemoved = userService.getUser(userId);

        if (userService.getRoleForUser(userToBeRemoved, shoppingListId) == ShoppingListRole.ADMIN) {
            throw new AccessDeniedException("An admin user can not be removed from the list.");
        }

        permissionsRepository.deleteByListAndUser(shoppingListId, userId);
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
    public void removeCategory(ShoppingList list, @Nullable String categoryName) {
        if (categoryName == null) {
            itemsRepository.findByList(list).forEach(ShoppingListItem::removeFromCategory);
            categoriesRepository.deleteByList(list);
        } else {
            categoriesRepository.findByNameAndList(categoryName, list).ifPresent(category -> {
                itemsRepository.findByListAndCategory(list, category).forEach(ShoppingListItem::removeFromCategory);
                categoriesRepository.delete(category);
            });
        }
    }

    public void renameCategory(ShoppingList list, String oldCategory, String newCategory) {
        categoriesRepository.findByNameAndList(oldCategory, list)
                .ifPresent(category -> renameCategory(list, category, newCategory));
    }

    private void renameCategory(ShoppingList list, ShoppingListCategory category, String newName) {
        ShoppingListCategory newCategory = categoriesRepository.findByNameAndList(newName, list).orElse(null);
        if (newCategory == null) {
            // No category with the new name exists in this list... just rename the category
            category.setName(newName);
            categoriesRepository.save(category);
            return;
        }

        // A category with the new name is already present... we can not have two categories with the same name.
        // Reassign all items of the old category to the already present category and delete the old category.
        transactionTemplate.executeWithoutResult(action -> {
            itemsRepository.findByListAndCategory(list, category).forEach(item -> item.setCategory(newCategory));
            categoriesRepository.delete(category);
        });
    }

    public void deleteAllItems(ShoppingList list) {
        itemsRepository.deleteByList(list);
    }

    public void deleteItemWithId(long listId, long itemId) {
        itemsRepository.deleteByListAndId(listId, itemId);
    }

    public void deleteCheckedItems(long listId, String ofCategory) {
        findShoppingList(listId).ifPresent(list -> deleteCheckedItems(list, ofCategory));
    }

    private void deleteCheckedItems(ShoppingList list, String ofCategory) {
        if (ofCategory == null) {
            itemsRepository.deleteByListAndChecked(list, true);
        } else {
            categoriesRepository.findByNameAndList(ofCategory, list).ifPresent(category -> {
                itemsRepository.deleteByListAndCheckedAndCategory(list, true, category);
            });
        }
    }

    public boolean moveShoppingListItem(ShoppingList list, ShoppingListItem item, int targetIndex) {
        // TODO: Implement
        return false;
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
            itemsRepository.save(item);
        });
    }
}
