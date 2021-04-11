package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;
import java.util.List;

import org.bson.types.ObjectId;

public class TestPendingRegistration extends PendingRegistration {

    public TestPendingRegistration(ObjectId id, String emailAddress, String userName, String password,
            String activationCode, ObjectId invitedBy, List<ObjectId> invitedToShoppingLists,
            LocalDateTime creationDate) {
        super(id, emailAddress, userName, password, activationCode, invitedBy, invitedToShoppingLists, creationDate);
    }

}
