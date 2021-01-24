package de.hanselmann.shoppinglist.restapi.dto.transformer;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListPermissionsDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserReferenceDto;

@Component
public class DtoTransformer {

    public List<ShoppingListItemDto> map(List<ShoppingListItem> shoppingListItems) {
        return shoppingListItems.stream().map(this::map).collect(Collectors.toList());
    }

    public ShoppingListItemDto map(ShoppingListItem item) {
        return new ShoppingListItemDto(item.getId(), item.getName(), item.isChecked(), item.getAssignee());
    }

    public ShoppingListUserReferenceDto map(ShoppingListUser user, ShoppingListRole userRole) {
        return new ShoppingListUserReferenceDto(user.getId().toString(), user.getUsername(), user.getEmailAddress(),
                mapShoppingListUserRole(userRole));
    }

    private ShoppingListPermissionsDto mapShoppingListUserRole(ShoppingListRole userRole) {
        switch (userRole) {
        case ADMIN:
            return new ShoppingListPermissionsDto(ShoppingListRole.ADMIN, true, true, true);
        case READ_WRITE:
            return new ShoppingListPermissionsDto(ShoppingListRole.READ_WRITE, false, true, true);
        case CHECK_ONLY:
            return new ShoppingListPermissionsDto(ShoppingListRole.CHECK_ONLY, false, false, true);
        case READ_ONLY:
        default:
            return new ShoppingListPermissionsDto(ShoppingListRole.READ_ONLY, false, false, false);
        }
    }

}
