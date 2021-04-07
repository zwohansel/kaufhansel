package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;
import java.util.List;

import org.bson.types.ObjectId;

public class TestShoppingListUser extends ShoppingListUser {

    public TestShoppingListUser(ObjectId id, boolean superUser, String username, String password,
            String emailAddress, LocalDateTime registrationDate, ObjectId invitedBy,
            List<ShoppingListReference> shoppingLists, String passwordResetCode,
            LocalDateTime passwordResetRequestedAt) {
        super(id, superUser, username, password, emailAddress, registrationDate, invitedBy, shoppingLists,
                passwordResetCode,
                passwordResetRequestedAt);
    }

}
