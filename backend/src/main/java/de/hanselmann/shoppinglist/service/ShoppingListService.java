package de.hanselmann.shoppinglist.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.Nullable;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionException;
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
    private TransactionTemplate transactionTemplate;

    @Autowired
    public ShoppingListService(ShoppingListRepository listsRepository,
            ShoppingListUserService userService,
            ShoppingListPermissionsRepository permissionsRepository,
            ShoppingListItemsRepository itemsRepository,
            ShoppingListCategoriesRepository categoriesRepository,
            JpaTransactionManager transactionManager) {
        this.listsRepository = listsRepository;
        this.userService = userService;
        this.permissionsRepository = permissionsRepository;
        this.itemsRepository = itemsRepository;
        this.categoriesRepository = categoriesRepository;
        transactionTemplate = new TransactionTemplate(transactionManager);
    }

    public @Nullable ShoppingList createShoppingListForCurrentUser(String name) {
        try {
            return transactionTemplate.execute(status -> createShoppingListForCurrentUserImpl(name));
        } catch (TransactionException e) {
            return null;
        }
    }

    ShoppingList createShoppingListForCurrentUserImpl(String name) {
        final var currentTime = LocalDateTime.now();
        final ShoppingListUser user = userService.getCurrentUser();
        var shoppingList = new ShoppingList(name, user, currentTime);
        var permission = new ShoppingListPermission(ShoppingListRole.ADMIN, user, shoppingList, currentTime);
        listsRepository.save(shoppingList);
        permissionsRepository.save(permission);
        if (shoppingList.getPermissions().stream().noneMatch(p -> p.getId().equals(permission.getId()))) {
            // TODO: Remove this block
            throw new IllegalStateException("Does not work as intended.");
        }
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

    private void addUserToShoppingList(ShoppingList list, ShoppingListUser user) {
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
        } catch (TransactionException e) {
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
     * @return List of processed items. If the transaction fails, null is returned.
     */
    public @Nullable List<ShoppingListItem> uncheckItems(ShoppingList list, @Nullable String category) {
        List<ShoppingListItem> itemsToUncheck = list.getItems().stream()
                .filter(ShoppingListItem::isChecked)
                .filter(item -> category == null || category.equals(item.getCategory().getName()))
                .collect(Collectors.toList());
        itemsToUncheck.forEach(item -> item.setChecked(false));
        itemsRepository.saveAll(itemsToUncheck);
        return itemsToUncheck;
    }

    /**
     * Remove categories of list.<br>
     * All categories, if category is null, only given category otherwise.
     * 
     * @param list         ShoppingList
     * @param categoryName The category with this name will be removed. If null, all
     *                     categories will be removed.
     */
    public void removeCategory(ShoppingList list, @Nullable String categoryName) {
        if (categoryName == null) {
            categoriesRepository.deleteByList(list);
        } else {
            categoriesRepository.deleteByNameAndList(categoryName, list);
        }
    }

    public void renameCategory(ShoppingList list, String oldCategory, String newCategory) {
        categoriesRepository.findByNameAndList(oldCategory, list).ifPresent(category -> {
            category.setName(newCategory);
            categoriesRepository.save(category);
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
            itemsRepository.deleteByListAndCheckedAndCategory(list, true, ofCategory);
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
