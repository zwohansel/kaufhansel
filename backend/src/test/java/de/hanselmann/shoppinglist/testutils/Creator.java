package de.hanselmann.shoppinglist.testutils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.bson.types.ObjectId;

import de.hanselmann.shoppinglist.model.PendingRegistration;
import de.hanselmann.shoppinglist.model.ShoppingListReference;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.model.TestPendingRegistration;
import de.hanselmann.shoppinglist.model.TestShoppingListUser;

public class Creator {

    public static ShoppingListUser userWithOneList(ObjectId userId) {
        List<ShoppingListReference> shoppingLists = new ArrayList<>();
        shoppingLists.add(new ShoppingListReference(new ObjectId(), ShoppingListRole.ADMIN));

        ShoppingListUser user = new TestShoppingListUser(userId, false, "Testuser", "secret", "test@test.de",
                null, null, shoppingLists, null, null);
        return user;
    }

    public static ShoppingListUser userWithOneList(ObjectId shoppingListId, ShoppingListRole role) {
        List<ShoppingListReference> shoppingLists = new ArrayList<>();
        shoppingLists.add(new ShoppingListReference(shoppingListId, role));

        ShoppingListUser user = new TestShoppingListUser(new ObjectId(), false, "Testuser", "secret", "test@test.de",
                null, null, shoppingLists, null, null);
        return user;
    }

    public static ShoppingListUser userWithTwoLists(ObjectId userId, ObjectId shoppingListId) {
        List<ShoppingListReference> shoppingLists = new ArrayList<>();
        shoppingLists.add(new ShoppingListReference(shoppingListId, ShoppingListRole.ADMIN));
        shoppingLists.add(new ShoppingListReference(new ObjectId(), ShoppingListRole.CHECK_ONLY));

        ShoppingListUser user = new TestShoppingListUser(userId, false, "Testuser", "secret", "test@test.de",
                null, null, shoppingLists, null, null);
        return user;
    }

    public static ShoppingListUser superUser(ObjectId userId) {
        List<ShoppingListReference> shoppingLists = new ArrayList<>();
        shoppingLists.add(new ShoppingListReference(new ObjectId(), ShoppingListRole.ADMIN));

        ShoppingListUser user = new TestShoppingListUser(userId, true, "Testuser", "secret", "test@test.de",
                null, null, shoppingLists, null, null);
        return user;
    }

    public static PendingRegistration pendingRegistration() {
        return pendingRegistration(LocalDateTime.now());
    }

    public static PendingRegistration pendingRegistration(LocalDateTime createdAt,
            ObjectId... invitedToShoppingListIds) {
        return new TestPendingRegistration(new ObjectId(), "test@test.de", "Testuser",
                "secret", "ACT1V3", new ObjectId(), Arrays.asList(invitedToShoppingListIds), createdAt);
    }

}
