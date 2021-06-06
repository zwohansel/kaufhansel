package de.hanselmann.shoppinglist.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import org.bson.types.ObjectId;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.mongodb.MongoTransactionManager;
import org.springframework.test.context.TestPropertySource;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.model.ShoppingListUserReference;
import de.hanselmann.shoppinglist.repository.ShoppingListRepository;
import de.hanselmann.shoppinglist.testutils.Creator;

@SpringBootTest(classes = { ShoppingListService.class })
@TestPropertySource(locations = "classpath:application-test.properties")
public class ShoppingListServiceIntegrationTest {

    @MockBean
    private ShoppingListRepository shoppingListRepository;

    @MockBean
    private ShoppingListUserService userService;

    @MockBean
    private MongoTransactionManager transactionManager;

    @Autowired
    private ShoppingListService cut;

    @Test
    public void renameList() {
        ObjectId shoppingListId = new ObjectId();
        ShoppingList shoppingList = Creator.shoppingList(shoppingListId);
        shoppingList.setName("old list name");

        when(shoppingListRepository.findById(eq(shoppingListId)))
                .thenReturn(Optional.of(shoppingList));

        cut.renameList(shoppingListId, "new list name");
        assertThat(shoppingList.getName()).isEqualTo("new list name");
        verify(shoppingListRepository)
                .save(argThat(arg -> arg.getId().equals(shoppingListId) && arg.getName().equals("new list name")));
    }

    @Test
    public void createShoppingListForCurrentUser() {
        ObjectId userId = new ObjectId();
        when(userService.getCurrentUser()).thenReturn(Creator.userWithOneListReference(userId));

        ShoppingList list = cut.createShoppingListForCurrentUserImpl("Neue Liste");
        assertThat(list.getName()).isEqualTo("Neue Liste");
        assertThat(list.getUsers().size()).isEqualTo(1);
        assertThat(list.getItems().size()).isEqualTo(0);
        verify(userService).addShoppingListToUser(
                argThat(arg -> arg.getId().equals(userId)), any(), eq(ShoppingListRole.ADMIN));
    }

    @Test
    public void addUserToShoppingList() {
        ObjectId shoppingListId = new ObjectId();
        ShoppingList shoppingList = Creator.shoppingList(shoppingListId);
        when(shoppingListRepository.findById(eq(shoppingListId)))
                .thenReturn(Optional.of(shoppingList));
        ObjectId userId = new ObjectId();
        ShoppingListUser user = Creator.userWithoutLists(userId);

        boolean success = cut.addUserToShoppingListImpl(shoppingListId, user);
        assertThat(success).isTrue();
        assertThat(shoppingList.getUsers().size()).isEqualTo(1);
        assertThat(shoppingList.getUsers().get(0).getUserId()).isEqualTo(userId);
        verify(userService).addShoppingListToUser(argThat(arg -> arg.getId().equals(userId)), eq(shoppingListId),
                eq(ShoppingListRole.READ_WRITE));
    }

    @Test
    public void doNotAddUserIfAlreadyInShoppingList() {
        ObjectId shoppingListId = new ObjectId();
        ObjectId userId = new ObjectId();
        ShoppingListUser user = Creator.userWithOneListReference(userId, shoppingListId);

        ShoppingList shoppingList = Creator.shoppingList(shoppingListId);
        shoppingList.addUser(new ShoppingListUserReference(userId));

        when(shoppingListRepository.findById(eq(shoppingListId)))
                .thenReturn(Optional.of(shoppingList));

        assertThrows(IllegalArgumentException.class, () -> cut.addUserToShoppingListImpl(shoppingListId, user));
    }

    @Test
    public void getFirstShoppingListOfUserFailsIfNoListIsPresent() {
        ObjectId userId = new ObjectId();
        ShoppingListUser user = Creator.userWithoutLists(userId);
        when(userService.getUser(eq(userId))).thenReturn(user);
        assertThrows(IllegalArgumentException.class, () -> cut.getFirstShoppingListOfUser(userId));
        verify(shoppingListRepository, never()).findById(any());
    }

    @Test
    public void createNewItem() {
        ShoppingList shoppingList = Creator.shoppingList();
        ShoppingListItem item = cut.createNewItem("New Item", "Category", shoppingList);
        assertThat(item.getName()).isEqualTo("New Item");
        assertThat(item.getCategory()).isEqualTo("Category");
        assertThat(shoppingList.getItems()).containsExactly(item);
    }

    @Test
    public void deleteShoppingList() {
        ObjectId shoppingListId = new ObjectId();
        ShoppingList shoppingList = Creator.shoppingList(shoppingListId);
        when(shoppingListRepository.findById(eq(shoppingListId))).thenReturn(Optional.of(shoppingList));
        ShoppingListUser user = addUserWithRole(shoppingList, ShoppingListRole.ADMIN);
        when(userService.getCurrentUser()).thenReturn(user);

        cut.tryDeleteShoppingList(shoppingListId);

        verify(shoppingListRepository, never()).save(any());
        verify(shoppingListRepository).deleteById(eq(shoppingListId));
    }

    @Test
    public void shoppingListIsNotDeletedIfOtherAdminIsPresent() {
        ObjectId shoppingListId = new ObjectId();
        ShoppingList shoppingList = Creator.shoppingList(shoppingListId);
        when(shoppingListRepository.findById(eq(shoppingListId))).thenReturn(Optional.of(shoppingList));

        ShoppingListUser user = addUserWithRole(shoppingList, ShoppingListRole.ADMIN);
        when(userService.getCurrentUser()).thenReturn(user);

        addUserWithRole(shoppingList, ShoppingListRole.ADMIN);

        assertThat(shoppingList.getUsers().size()).isEqualTo(2);

        cut.tryDeleteShoppingList(shoppingListId);
        assertThat(shoppingList.getUsers().size()).isEqualTo(1);
        verify(shoppingListRepository).save(
                argThat(arg -> arg.getId().equals(shoppingListId) && arg.getUsers().size() == 1));
        verify(shoppingListRepository, never()).deleteById(any());
    }

    @Test
    public void shoppingListIsDeletedIfOtherNonAdminUsersArePresent() {
        ObjectId shoppingListId = new ObjectId();
        ShoppingList shoppingList = Creator.shoppingList(shoppingListId);
        when(shoppingListRepository.findById(eq(shoppingListId))).thenReturn(Optional.of(shoppingList));

        ShoppingListUser user = addUserWithRole(shoppingList, ShoppingListRole.ADMIN);
        when(userService.getCurrentUser()).thenReturn(user);

        addUserWithRole(shoppingList, ShoppingListRole.READ_WRITE);

        assertThat(shoppingList.getUsers().size()).isEqualTo(2);

        cut.tryDeleteShoppingList(shoppingListId);
        verify(shoppingListRepository, never()).save(any());
        verify(shoppingListRepository).deleteById(eq(shoppingListId));
    }

    private ShoppingListUser addUserWithRole(ShoppingList shoppingList, ShoppingListRole role) {
        ObjectId userId = new ObjectId();
        ShoppingListUser user = Creator.userWithOneListReference(userId, shoppingList.getId());
        ShoppingListUserReference userRef = new ShoppingListUserReference(userId);
        shoppingList.addUser(userRef);
        when(userService.getRoleForUser(eq(userId), eq(shoppingList.getId()))).thenReturn(role);
        return user;
    }

    @Test
    public void removeUserFromShoppingList() {
        ObjectId shoppingListId = new ObjectId();
        ObjectId userId = new ObjectId();
        ShoppingList shoppingList = Creator.shoppingList(shoppingListId);
        ShoppingListUserReference userRef = new ShoppingListUserReference(userId);
        shoppingList.addUser(userRef);
        when(shoppingListRepository.findById(shoppingListId)).thenReturn(Optional.of(shoppingList));

        assertThat(shoppingList.getUsers().size()).isEqualTo(1);
        cut.removeUserFromShoppingList(shoppingListId, userId);
        assertThat(shoppingList.getUsers()).isEmpty();
        verify(shoppingListRepository).save(argThat(arg -> arg.getId().equals(shoppingListId)));
    }

    @Test
    public void uncheckItems() {
        ObjectId shoppingListId = new ObjectId();
        ShoppingList shoppingList = buildListWithItems(shoppingListId);

        List<ShoppingListItem> uncheckedItems = cut.uncheckItemsImpl(shoppingList, "category1");
        assertThat(uncheckedItems.size()).isEqualTo(1);
        assertThat(uncheckedItems.get(0)).matches(i -> i.getName().equals("item2") && !i.isChecked());
        verify(shoppingListRepository).save(argThat(arg -> arg.getId().equals(shoppingListId)));
    }

    @Test
    public void removeCategories() {
        ObjectId shoppingListId = new ObjectId();
        ShoppingList shoppingList = buildListWithItems(shoppingListId);

        List<ShoppingListItem> changedItems = cut.removeCategoryImpl(shoppingList, "category1");
        assertThat(changedItems.size()).isEqualTo(2);
        assertThat(changedItems.stream().map(ShoppingListItem::getCategory)).allMatch(s -> s.equals(""));
        verify(shoppingListRepository).save(argThat(arg -> arg.getId().equals(shoppingListId)));
    }

    @Test
    public void renameCategory() {
        ObjectId shoppingListId = new ObjectId();
        ShoppingList shoppingList = buildListWithItems(shoppingListId);

        List<ShoppingListItem> changedItems = cut.renameCategoryImpl(shoppingList, "category1", "new name");
        assertThat(changedItems.size()).isEqualTo(2);
        assertThat(changedItems.stream().map(ShoppingListItem::getCategory)).allMatch(s -> s.equals("new name"));
        verify(shoppingListRepository).save(argThat(arg -> arg.getId().equals(shoppingListId)));
    }

    private ShoppingList buildListWithItems(ObjectId shoppingListId) {
        ShoppingList shoppingList = Creator.shoppingList(shoppingListId,
                Creator.item("item1", null, true),
                Creator.item("item2", "category1", true),
                Creator.item("item3", "category1", false),
                Creator.item("item4", "category2", true),
                Creator.item("item5", null, false));
        return shoppingList;
    }

    @Test
    public void removeAllItems() {
        ObjectId item1Id = new ObjectId();
        ObjectId item2Id = new ObjectId();
        ObjectId item3Id = new ObjectId();
        ObjectId shoppingListId = new ObjectId();
        ShoppingList shoppingList = Creator.shoppingList(shoppingListId,
                Creator.item(item1Id, "item1"),
                Creator.item(item2Id, "item2"),
                Creator.item(item3Id, "item3"));

        List<ShoppingListItem> removedItems = cut.removeAllItemsImpl(shoppingList);
        assertThat(removedItems.stream().map(ShoppingListItem::getId)).containsExactlyInAnyOrder(item1Id, item2Id,
                item3Id);
        assertThat(shoppingList.getItems()).isEmpty();
        verify(shoppingListRepository)
                .save(argThat(arg -> arg.getId().equals(shoppingListId) && arg.getItems().isEmpty()));
    }

    @Test
    public void removeItems() {
        ObjectId item1Id = new ObjectId();
        ObjectId item2Id = new ObjectId();
        ObjectId item3Id = new ObjectId();
        ObjectId shoppingListId = new ObjectId();
        ShoppingList shoppingList = Creator.shoppingList(shoppingListId,
                Creator.item(item1Id, "item1"),
                Creator.item(item2Id, "item2"),
                Creator.item(item3Id, "item3"));

        List<ShoppingListItem> removedItems = cut.removeItemsImpl(shoppingList, Arrays.asList(item1Id, item2Id));
        assertThat(removedItems.size()).isEqualTo(2);
        assertThat(removedItems.stream().map(ShoppingListItem::getId)).containsExactlyInAnyOrder(item1Id, item2Id);
        assertThat(shoppingList.getItems()).anyMatch(i -> i.getId().equals(item3Id));
        verify(shoppingListRepository)
                .save(argThat(arg -> arg.getId().equals(shoppingListId) && arg.getItems().size() == 1));
    }

    @Test
    public void moveShoppingListItem() {
        ShoppingListItem item1 = Creator.item(new ObjectId(), "item1");
        ShoppingListItem item2 = Creator.item(new ObjectId(), "item2");
        ShoppingListItem item3 = Creator.item(new ObjectId(), "item3");
        ObjectId shoppingListId = new ObjectId();
        ShoppingList shoppingList = Creator.shoppingList(shoppingListId,
                item1, item2, item3);
        assertThat(shoppingList.getItems()).containsExactly(item1, item2, item3);

        // top
        cut.moveShoppingListItem(shoppingList, item2, 0);
        assertThat(shoppingList.getItems()).containsExactly(item2, item1, item3);

        // same position
        cut.moveShoppingListItem(shoppingList, item2, 0);
        assertThat(shoppingList.getItems()).containsExactly(item2, item1, item3);

        // end
        cut.moveShoppingListItem(shoppingList, item2, 2);
        assertThat(shoppingList.getItems()).containsExactly(item1, item3, item2);

        // positive index out of bounds moves to end
        cut.moveShoppingListItem(shoppingList, item1, 99);
        assertThat(shoppingList.getItems()).containsExactly(item3, item2, item1);

        // negative index throws exception
        assertThrows(IndexOutOfBoundsException.class, () -> cut.moveShoppingListItem(shoppingList, item2, -1));
    }

}
