package de.hanselmann.shoppinglist.restapi.dto.transformer;

import java.util.List;
import java.util.stream.Collectors;

import org.bson.types.ObjectId;
import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.model.InfoMessage;
import de.hanselmann.shoppinglist.model.InfoMessage.Severity;
import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.model.ShoppingListReference;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.restapi.dto.InfoDto.InfoMessageDto;
import de.hanselmann.shoppinglist.restapi.dto.InfoDto.SeverityDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationProcessTypeDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListPermissionsDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserReferenceDto;
import de.hanselmann.shoppinglist.service.RegistrationService.RegistrationProcessType;

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

    public ShoppingListUserInfoDto map(ShoppingListUser user, String token) {
        return new ShoppingListUserInfoDto(user.getId().toString(), token, user.getUsername(), user.getEmailAddress());
    }

    public ShoppingListPermissionsDto map(ShoppingListRole userRole) {
        return new ShoppingListPermissionsDto(userRole);
    }

    public ShoppingListInfoDto map(
            ShoppingList list,
            ShoppingListPermissionsDto userPermissions,
            List<ShoppingListUserReferenceDto> otherUsers) {
        return new ShoppingListInfoDto(list.getId().toString(), list.getName(), userPermissions, otherUsers);
    }

    public RegistrationProcessTypeDto map(RegistrationProcessType typeOfRegistrationProcess) {
        switch (typeOfRegistrationProcess) {
        case FULL_REGISTRATION:
            return RegistrationProcessTypeDto.fullRegistration();
        case WITHOUT_EMAIL:
            return RegistrationProcessTypeDto.withoutEmail();
        default:
            return RegistrationProcessTypeDto.inviteInvalid();
        }
    }

    public InfoMessageDto map(InfoMessage message) {
        return new InfoMessageDto(map(message.getSeverity()), message.getMessage(), message.getDismissLabel());
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
