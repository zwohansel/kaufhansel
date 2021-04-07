package de.hanselmann.shoppinglist.restapi.dto.transformer;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Arrays;
import java.util.List;

import org.bson.types.ObjectId;
import org.junit.jupiter.api.Test;

import de.hanselmann.shoppinglist.model.ShoppingListReference;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.model.TestShoppingListUser;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserReferenceDto;

public class DtoTransformerTest {

    private final DtoTransformer dtoTransformer = new DtoTransformer();

    @Test
    public void mapUserToShoppingListUserReference() {
        ObjectId shoppingListId = new ObjectId();
        List<ShoppingListReference> shoppingLists = Arrays.asList(
                new ShoppingListReference(shoppingListId, ShoppingListRole.ADMIN),
                new ShoppingListReference(new ObjectId(), ShoppingListRole.CHECK_ONLY));

        ObjectId userId = new ObjectId();
        ShoppingListUser user = new TestShoppingListUser(userId, false, "Testuser", "secret", "mail@online.de",
                null, null, shoppingLists, null, null);

        ShoppingListUserReferenceDto referenceDto = dtoTransformer.map(user, shoppingListId);
        assertThat(referenceDto.getuserRole()).isEqualTo(ShoppingListRole.ADMIN);
        assertThat(referenceDto.getUserId()).isEqualTo(userId.toString());
        assertThat(referenceDto.getUserName()).isEqualTo("Testuser");
        assertThat(referenceDto.getUserEmailAddress()).isEqualTo("mail@online.de");
    }

}
