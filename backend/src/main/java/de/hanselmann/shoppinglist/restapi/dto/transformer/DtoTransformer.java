package de.hanselmann.shoppinglist.restapi.dto.transformer;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserReferenceDto;

@Component
public class DtoTransformer {

    public List<ShoppingListItemDto> map(List<ShoppingListItem> shoppingListItems) {
        return shoppingListItems.stream().map(this::map).collect(Collectors.toList());
    }

    public ShoppingListItemDto map(ShoppingListItem item) {
        return new ShoppingListItemDto(item.getId(), item.getName(), item.isChecked(), item.getAssignee());
    }

    public ShoppingListUserReferenceDto map(ShoppingListUser user) {
        return new ShoppingListUserReferenceDto(user.getId().toString(), user.getUsername(), user.getEmailAdress());
    }

}
