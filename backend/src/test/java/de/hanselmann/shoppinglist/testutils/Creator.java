package de.hanselmann.shoppinglist.testutils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.bson.types.ObjectId;

import de.hanselmann.shoppinglist.model.ListInvite;
import de.hanselmann.shoppinglist.model.PendingRegistration;
import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.model.ShoppingListPermission;
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

    public static ShoppingListUser userWithOneListReference(ObjectId userId) {
        List<ShoppingListPermission> shoppingLists = new ArrayList<>();
        shoppingLists.add(new ShoppingListPermission(new ObjectId(), ShoppingListRole.ADMIN));

        return new TestShoppingListUser(userId, false, "Testuser", "secret", "test@test.de",
                null, null, shoppingLists, null, null);
    }

    public static ShoppingListUser userWithOneListReference(ObjectId userId, ObjectId shoppingListId) {
        List<ShoppingListPermission> shoppingLists = new ArrayList<>();
        shoppingLists.add(new ShoppingListPermission(shoppingListId, ShoppingListRole.ADMIN));

        return new TestShoppingListUser(userId, false, "Testuser", "secret", "test@test.de",
                null, null, shoppingLists, null, null);
    }

    public static ShoppingListUser userWithOneListReference(ObjectId shoppingListId, ShoppingListRole role) {
        List<ShoppingListPermission> shoppingLists = new ArrayList<>();
        shoppingLists.add(new ShoppingListPermission(shoppingListId, role));

        return new TestShoppingListUser(new ObjectId(), false, "Testuser", "secret", "test@test.de",
                null, null, shoppingLists, null, null);
    }

    public static ShoppingListUser userWithTwoListReferences(ObjectId userId, ObjectId shoppingListId) {
        return userWithCheckOnlyListReferenceAnd(userId, shoppingListId, ShoppingListRole.ADMIN);
    }

    public static ShoppingListUser userWithCheckOnlyListReferenceAnd(ObjectId userId, ObjectId shoppingListId,
            ShoppingListRole role) {
        List<ShoppingListPermission> shoppingLists = new ArrayList<>();
        shoppingLists.add(new ShoppingListPermission(shoppingListId, role));
        shoppingLists.add(new ShoppingListPermission(new ObjectId(), ShoppingListRole.CHECK_ONLY));

        return new TestShoppingListUser(userId, false, "Testuser", "secret", "test@test.de",
                null, null, shoppingLists, null, null);
    }

    public static ShoppingListUser superUser(ObjectId userId) {
        List<ShoppingListPermission> shoppingLists = new ArrayList<>();
        shoppingLists.add(new ShoppingListPermission(new ObjectId(), ShoppingListRole.ADMIN));

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

    public static ListInvite invite(String code) {
        return new TestInvite(new ObjectId(), code, null, null, null, new ArrayList<>());
    }

    public static ListInvite invite(String code, String inviteeEmailAddress) {
        return new TestInvite(new ObjectId(), code, null, null, inviteeEmailAddress, new ArrayList<>());
    }

    public static ShoppingList shoppingList() {
        return shoppingList(new ObjectId());
    }

    public static ShoppingList shoppingList(ObjectId shoppingListId) {
        return new TestShoppingList(shoppingListId, null, new ArrayList<>(), new ArrayList<>());
    }

    public static ShoppingList shoppingList(ObjectId shoppingListId, ShoppingListItem... items) {
        return new TestShoppingList(shoppingListId, null, Stream.of(items).collect(Collectors.toList()),
                new ArrayList<>());
    }

    public static ShoppingListItem item(String name, String category, boolean checked) {
        ShoppingListItem item = new ShoppingListItem(name);
        item.setCategory(category);
        item.setChecked(checked);
        return item;
    }

    public static ShoppingListItem item(ObjectId itemId, String name) {
        ShoppingListItem item = new ShoppingListItem(name);
        item.setId(itemId);
        return item;
    }

}
