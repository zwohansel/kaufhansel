package de.hanselmann.shoppinglist.testutils;

import de.hanselmann.shoppinglist.AddListItemEndpointTest;
import de.hanselmann.shoppinglist.UpdateListItemEndpointTest;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemUpdateDto;
import org.springframework.test.web.servlet.client.RestTestClient;

public class ListItemBuilder {
    private final RestTestClient client;
    private final ShoppingListInfoDto list;

    private ListItemBuilder(RestTestClient client, ShoppingListInfoDto list) {
        this.client = client;
        this.list = list;
    }

    public static ListItemBuilder forList(RestTestClient webClient, ShoppingListInfoDto list) {
        return new ListItemBuilder(webClient, list);
    }

    public ItemBuilder itemWithName(String name) {
        return new ItemBuilder(name);
    }

    public class ItemBuilder {
        private final String name;
        private String category;
        private boolean checked;

        private ItemBuilder(String name) {
            this.name = name;
        }

        public ItemBuilder andCategory(String category) {
            this.category = category;
            return this;
        }

        public ItemBuilder andCheckedState(boolean checked) {
            this.checked = checked;
            return this;
        }

        public ListItemBuilder add() {
            final RestTestClient webClient = ListItemBuilder.this.client;
            final ShoppingListInfoDto list = ListItemBuilder.this.list;

            var newItem = new NewShoppingListItemDto();
            newItem.setName(name);
            newItem.setCategory(category);
            ShoppingListItemDto item = AddListItemEndpointTest.addListItem(webClient, list, newItem);

            if (checked) {
                ShoppingListItemUpdateDto updateItem = new ShoppingListItemUpdateDto();
                updateItem.setName(name);
                updateItem.setCategory(category);
                updateItem.setChecked(true);
                UpdateListItemEndpointTest.updateListItem(webClient, list, item, updateItem);
            }
            return ListItemBuilder.this;
        }
    }
}
