package de.hanselmann.shoppinglist.restapi.dto.transformer;

import java.util.List;
import java.util.stream.Collectors;

import org.bson.types.ObjectId;
import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.model.ShoppingListReference;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListPermissionsDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserReferenceDto;

@Component
public class DtoTransformer {

    public List<ShoppingListItemDto> map(List<ShoppingListItem> shoppingListItems) {
        return shoppingListItems.stream().map(this::map).collect(Collectors.toList());
    }

    public ShoppingListItemDto map(ShoppingListItem item) {
        return new ShoppingListItemDto(item.getId(), item.getName(), item.isChecked(), item.getAssignee());
    }

    public ShoppingListUserReferenceDto map(ShoppingListUser user, ObjectId shoppingListId) {
        ShoppingListRole role = user.getShoppingLists().stream()
                .filter(ref -> ref.getShoppingListId().equals(shoppingListId))
                .findAny()
                .map(ShoppingListReference::getRole)
                .orElseThrow(() -> new IllegalArgumentException("User does not know that list."));

        return new ShoppingListUserReferenceDto(
                user.getId().toString(),
                user.getUsername(),
                user.getEmailAddress(),
                role);
    }

    public ShoppingListUserInfoDto map(ShoppingListUser user) {
        return new ShoppingListUserInfoDto(user.getId().toString(), user.getUsername(), user.getEmailAddress());
    }

    public ShoppingListPermissionsDto map(ShoppingListRole userRole) {
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

    public ShoppingListInfoDto map(
            ShoppingList list,
            ShoppingListPermissionsDto userPermissions,
            List<ShoppingListUserReferenceDto> otherUsers) {
        return new ShoppingListInfoDto(list.getId().toString(), list.getName(), userPermissions, otherUsers);
    }

}
