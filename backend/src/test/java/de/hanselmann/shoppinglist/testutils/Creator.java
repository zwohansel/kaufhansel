package de.hanselmann.shoppinglist.testutils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.bson.types.ObjectId;

import de.hanselmann.shoppinglist.model.Invite;
import de.hanselmann.shoppinglist.model.PendingRegistration;
import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListReference;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.model.TestInvite;
import de.hanselmann.shoppinglist.model.TestPendingRegistration;
import de.hanselmann.shoppinglist.model.TestShoppingList;
import de.hanselmann.shoppinglist.model.TestShoppingListUser;

public class Creator {

    /**
     * @return just a non-null ShoppingListUser
     */
    public static ShoppingListUser emptyUser() {
        return new TestShoppingListUser(null, false, null, null, null, null, null, null, null, null);
    }

    public static ShoppingListUser userWithoutLists(ObjectId userId) {
        return new TestShoppingListUser(userId, false, "Testuser", "secret", "test@test.de",
                null, null, new ArrayList<>(), null, null);
    }

    public static ShoppingListUser userWithOneList(ObjectId userId) {
        List<ShoppingListReference> shoppingLists = new ArrayList<>();
        shoppingLists.add(new ShoppingListReference(new ObjectId(), ShoppingListRole.ADMIN));

        return new TestShoppingListUser(userId, false, "Testuser", "secret", "test@test.de",
                null, null, shoppingLists, null, null);
    }

    public static ShoppingListUser userWithOneList(ObjectId userId, ObjectId shoppingListId) {
        List<ShoppingListReference> shoppingLists = new ArrayList<>();
        shoppingLists.add(new ShoppingListReference(shoppingListId, ShoppingListRole.ADMIN));

        return new TestShoppingListUser(userId, false, "Testuser", "secret", "test@test.de",
                null, null, shoppingLists, null, null);
    }

    public static ShoppingListUser userWithOneList(ObjectId shoppingListId, ShoppingListRole role) {
        List<ShoppingListReference> shoppingLists = new ArrayList<>();
        shoppingLists.add(new ShoppingListReference(shoppingListId, role));

        return new TestShoppingListUser(new ObjectId(), false, "Testuser", "secret", "test@test.de",
                null, null, shoppingLists, null, null);
    }

    public static ShoppingListUser userWithTwoLists(ObjectId userId, ObjectId shoppingListId) {
        return userWithCheckOnlyListAnd(userId, shoppingListId, ShoppingListRole.ADMIN);
    }

    public static ShoppingListUser userWithCheckOnlyListAnd(ObjectId userId, ObjectId shoppingListId,
            ShoppingListRole role) {
        List<ShoppingListReference> shoppingLists = new ArrayList<>();
        shoppingLists.add(new ShoppingListReference(shoppingListId, role));
        shoppingLists.add(new ShoppingListReference(new ObjectId(), ShoppingListRole.CHECK_ONLY));

        return new TestShoppingListUser(userId, false, "Testuser", "secret", "test@test.de",
                null, null, shoppingLists, null, null);
    }

    public static ShoppingListUser superUser(ObjectId userId) {
        List<ShoppingListReference> shoppingLists = new ArrayList<>();
        shoppingLists.add(new ShoppingListReference(new ObjectId(), ShoppingListRole.ADMIN));

        return new TestShoppingListUser(userId, true, "Testuser", "secret", "test@test.de",
                null, null, shoppingLists, null, null);
    }

    public static PendingRegistration pendingRegistration() {
        return pendingRegistration(LocalDateTime.now());
    }

    public static PendingRegistration pendingRegistration(LocalDateTime createdAt) {
        return new TestPendingRegistration(new ObjectId(), "test@test.de", "Testuser",
                "secret", "ACT1V3", new ObjectId(), new ArrayList<>(), createdAt);
    }

    public static PendingRegistration pendingRegistration(LocalDateTime createdAt,
            ObjectId... invitedToShoppingListIds) {
        return new TestPendingRegistration(new ObjectId(), "test@test.de", "Testuser",
                "secret", "ACT1V3", new ObjectId(), Arrays.asList(invitedToShoppingListIds), createdAt);
    }

    public static Invite invite(String code) {
        return new TestInvite(new ObjectId(), code, null, null, null, new ArrayList<>());
    }

    public static Invite invite(String code, String inviteeEmailAddress) {
        return new TestInvite(new ObjectId(), code, null, null, inviteeEmailAddress, new ArrayList<>());
    }

    public static ShoppingList shoppingList() {
        return shoppingList(new ObjectId());
    }

    public static ShoppingList shoppingList(ObjectId id) {
        return new TestShoppingList(id, null, new ArrayList<>(), new ArrayList<>());
    }

}
