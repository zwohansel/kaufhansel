package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;
import java.util.List;

import org.bson.types.ObjectId;

public class TestInvite extends ListInvite {

    public TestInvite(ObjectId id, String code, ObjectId generatedByUser, LocalDateTime generatedAt,
            String inviteeEmailAddress, List<ObjectId> invitedToShoppingLists) {
        super(id, code, generatedByUser, generatedAt, inviteeEmailAddress, invitedToShoppingLists);
    }

}
