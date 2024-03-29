package de.hanselmann.shoppinglist.restapi.dto.transformer;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.model.InfoMessage;
import de.hanselmann.shoppinglist.model.InfoMessage.Severity;
import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.model.ShoppingListPermission;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.restapi.dto.InfoDto.InfoMessageDto;
import de.hanselmann.shoppinglist.restapi.dto.InfoDto.SeverityDto;
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
        return new ShoppingListItemDto(Long.toString(item.getId()), item.getName(), item.isChecked(),
                item.getCategoryName());
    }

    public ShoppingListUserReferenceDto map(ShoppingListUser user, long shoppingListId) {
        ShoppingListRole role = user.getShoppingListPermissions().stream()
                .filter(permission -> permission.getList().getId() == shoppingListId)
                .findAny()
                .map(ShoppingListPermission::getRole)
                .orElseThrow(() -> new IllegalArgumentException("User does not know that list."));

        return new ShoppingListUserReferenceDto(
                Long.toString(user.getId()),
                user.getUsername(),
                user.getEmailAddress(),
                role);
    }

    public ShoppingListUserInfoDto map(ShoppingListUser user, String token) {
        return new ShoppingListUserInfoDto(Long.toString(user.getId()), token, user.getUsername(),
                user.getEmailAddress());
    }

    public ShoppingListPermissionsDto map(ShoppingListRole userRole) {
        return new ShoppingListPermissionsDto(userRole);
    }

    public ShoppingListInfoDto map(
            ShoppingList list,
            ShoppingListPermissionsDto userPermissions,
            List<ShoppingListUserReferenceDto> otherUsers) {
        return new ShoppingListInfoDto(Long.toString(list.getId()), list.getName(), userPermissions, otherUsers);
    }

    public InfoMessageDto map(InfoMessage message) {
        return new InfoMessageDto(message.getId(), map(message.getSeverity()), message.getMessage(),
                message.getDismissLabel());
    }

    private SeverityDto map(Severity severity) {
        switch (severity) {
        case CRITICAL:
            return SeverityDto.CRITICAL;
        case INFO:
        default:
            return SeverityDto.INFO;
        }
    }

}
