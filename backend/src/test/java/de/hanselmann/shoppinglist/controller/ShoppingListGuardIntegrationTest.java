package de.hanselmann.shoppinglist.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

import java.util.Optional;
import java.util.stream.Stream;

import org.bson.types.ObjectId;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.TestPropertySource;

import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.service.ShoppingListUserService;
import de.hanselmann.shoppinglist.testutils.Creator;

@SpringBootTest(classes = { ShoppingListGuard.class })
@TestPropertySource(locations = "classpath:application-test.properties")
public class ShoppingListGuardIntegrationTest {

    @MockBean
    private ShoppingListUserService userService;

    @Autowired
    private ShoppingListGuard cut;

    @Test
    public void testCanAccessShoppingList() {
        ObjectId shoppingListId = mockUserWithShoppingList(ShoppingListRole.ADMIN);
        assertThat(cut.canAccessShoppingList(shoppingListId)).isTrue();
        assertThat(cut.canAccessShoppingList(new ObjectId())).isFalse();
    }

    @ParameterizedTest
    @MethodSource("canEditItems")
    public void testCanEditItemsInShoppingList(ShoppingListRole role, boolean expected) {
        ObjectId shoppingListId = mockUserWithShoppingList(role);
        assertThat(cut.canEditItemsInShoppingList(shoppingListId)).isEqualTo(expected);
    }

    private static Stream<Arguments> canEditItems() {
        return Stream.of(
                Arguments.of(ShoppingListRole.ADMIN, true),
                Arguments.of(ShoppingListRole.READ_WRITE, true),
                Arguments.of(ShoppingListRole.CHECK_ONLY, false),
                Arguments.of(ShoppingListRole.READ_ONLY, false));
    }

    @ParameterizedTest
    @MethodSource("canCheckItems")
    public void testCanCheckItemsInShoppingList(ShoppingListRole role, boolean expected) {
        ObjectId shoppingListId = mockUserWithShoppingList(role);
        assertThat(cut.canCheckItemsInShoppingList(shoppingListId)).isEqualTo(expected);
    }

    private static Stream<Arguments> canCheckItems() {
        return Stream.of(
                Arguments.of(ShoppingListRole.ADMIN, true),
                Arguments.of(ShoppingListRole.READ_WRITE, true),
                Arguments.of(ShoppingListRole.CHECK_ONLY, true),
                Arguments.of(ShoppingListRole.READ_ONLY, false));
    }

    @ParameterizedTest
    @MethodSource("canEditShoppingList")
    public void testCanEditShoppingList(ShoppingListRole role, boolean expected) {
        ObjectId shoppingListId = mockUserWithShoppingList(role);
        assertThat(cut.canEditShoppingList(shoppingListId)).isEqualTo(expected);
    }

    private static Stream<Arguments> canEditShoppingList() {
        return Stream.of(
                Arguments.of(ShoppingListRole.ADMIN, true),
                Arguments.of(ShoppingListRole.READ_WRITE, false),
                Arguments.of(ShoppingListRole.CHECK_ONLY, false),
                Arguments.of(ShoppingListRole.READ_ONLY, false));
    }

    private ObjectId mockUserWithShoppingList(ShoppingListRole role) {
        ObjectId shoppingListId = new ObjectId();
        ShoppingListUser user = Creator.userWithOneListReference(shoppingListId, role);
        when(userService.findCurrentUser()).thenReturn(Optional.of(user));
        return shoppingListId;
    }

    @Test
    public void testCantDeleteSuperUser() {
        ObjectId superUserId = new ObjectId();
        ShoppingListUser superUser = Creator.superUser(superUserId);

        when(userService.findUser(eq(superUserId))).thenReturn(Optional.of(superUser));
        when(userService.getCurrentUser()).thenReturn(superUser);

        assertThat(cut.canDeleteUser(superUserId)).isFalse();
    }

    @Test
    public void testSuperUserCanDeleteAnyOtherUser() {
        ObjectId userToBeDeletedId = new ObjectId();
        ShoppingListUser userToBeDeleted = Creator.userWithOneListReference(userToBeDeletedId);
        when(userService.findUser(eq(userToBeDeletedId))).thenReturn(Optional.of(userToBeDeleted));

        ObjectId superUserId = new ObjectId();
        ShoppingListUser superUser = Creator.superUser(superUserId);

        when(userService.getCurrentUser()).thenReturn(superUser);

        assertThat(cut.canDeleteUser(userToBeDeletedId)).isTrue();
    }

    @Test
    public void testUserCanDelteOwnAccount() {
        ObjectId userId = new ObjectId();
        ShoppingListUser user = Creator.userWithOneListReference(userId);

        when(userService.findUser(eq(userId))).thenReturn(Optional.of(user));
        when(userService.getCurrentUser()).thenReturn(user);

        assertThat(cut.canDeleteUser(userId)).isTrue();
    }
}
