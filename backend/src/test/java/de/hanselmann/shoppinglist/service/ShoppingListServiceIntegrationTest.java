package de.hanselmann.shoppinglist.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

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
    public void createShoppingListForCurrentUser() {
        ObjectId userId = new ObjectId();
        when(userService.getCurrentUser()).thenReturn(Creator.userWithOneList(userId));

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
        ShoppingListUser user = Creator.userWithOneList(userId, shoppingListId);

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
        assertThat(item.getAssignee()).isEqualTo("Category");
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
        ShoppingListUser user = Creator.userWithOneList(userId, shoppingList.getId());
        ShoppingListUserReference userRef = new ShoppingListUserReference(userId);
        shoppingList.addUser(userRef);
        when(userService.getRoleForUser(eq(userId), eq(shoppingList.getId()))).thenReturn(role);
        return user;
    }

    @Test
    public void removeUserFromShoppingList() {
    }

    @Test
    public void uncheckItems() {
    }

    @Test
    public void removeCategories() {
    }

    @Test
    public void renameCategory() {
    }

    @Test
    public void removeItems() {
    }

    @Test
    public void removeAllItems() {
    }

    @Test
    public void moveShoppingListItem() {
    }

    @Test
    public void renameList() {
    }

    @Test
    public void deleteOrLeaveShoppingListsOfUser() {
    }

}
