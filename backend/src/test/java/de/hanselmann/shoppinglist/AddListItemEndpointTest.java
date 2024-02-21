package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;

import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class AddListItemEndpointTest {
    private static final String PATH = "/api/shoppinglist/{id}";

    @Autowired
    private WebTestClient webClient;

    public static ShoppingListItemDto addListItem(WebTestClient webClient, ShoppingListInfoDto list,
            NewShoppingListItemDto newItem) {
        return webClient.post()
                .uri(PATH, list.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(newItem)
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBody(ShoppingListItemDto.class)
                .returnResult()
                .getResponseBody();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void addNewShoppingListItemWithoutCategory() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        var newItem = new NewShoppingListItemDto();
        newItem.setName("New Item");

        ShoppingListItemDto createdItem = addListItem(client, list, newItem);

        assertThat(createdItem.getName()).as("Item has expected name.").isEqualTo(newItem.getName());
        assertThat(createdItem.getCategory()).as("Item has no category.").isNull();
        assertThat(createdItem.isChecked()).as("Item is not checked").isFalse();

        List<ShoppingListItemDto> items = GetListItemsEndpointTest.getListItems(client, list);

        assertThat(items).as(PATH + " returns created item").singleElement();
        assertThat(items.get(0).getName()).as("Item has expected name.").isEqualTo(newItem.getName());
        assertThat(items.get(0).getCategory()).as("Item has no category.").isNull();
        assertThat(items.get(0).isChecked()).as("Item is not checked").isFalse();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void addNewShoppingListItemWithCategory() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        var newItem = new NewShoppingListItemDto();
        newItem.setName("New Item");
        newItem.setCategory("New Category");

        ShoppingListItemDto createdItem = addListItem(client, list, newItem);

        assertThat(createdItem.getName()).as("Item has expected name.").isEqualTo(newItem.getName());
        assertThat(createdItem.getCategory()).as("Item has expected category.").isEqualTo(newItem.getCategory());
        assertThat(createdItem.isChecked()).as("Item is not checked").isFalse();

        List<ShoppingListItemDto> items = GetListItemsEndpointTest.getListItems(client, list);

        assertThat(items).as("/shoppinglist/{id} returns created item").singleElement();
        assertThat(items.get(0).getName()).as("Item has expected name.").isEqualTo(newItem.getName());
        assertThat(items.get(0).getCategory()).as("Item has expected category.").isEqualTo(newItem.getCategory());
        assertThat(items.get(0).isChecked()).as("Item is not checked").isFalse();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void shoppingListItemsAreReturnedInTheOrderOfCreation() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        var newItem1 = new NewShoppingListItemDto();
        newItem1.setName("Item 1");
        newItem1.setCategory("Category I");

        var newItem2 = new NewShoppingListItemDto();
        newItem2.setName("Item 2");
        newItem2.setCategory("Category I");

        var newItem3 = new NewShoppingListItemDto();
        newItem3.setName("Item 3");
        newItem3.setCategory("Category II");

        addListItem(client, list, newItem1);
        addListItem(client, list, newItem2);
        addListItem(client, list, newItem3);

        List<ShoppingListItemDto> items = GetListItemsEndpointTest.getListItems(client, list);

        assertThat(items).as("/shoppinglist/{id} returns created items").hasSize(3);

        assertThat(items.get(0).getName()).as("Item 1 has expected name.").isEqualTo(newItem1.getName());
        assertThat(items.get(0).getCategory()).as("Item 1 has expected category.").isEqualTo(newItem1.getCategory());
        assertThat(items.get(0).isChecked()).as("Item 1 is not checked").isFalse();

        assertThat(items.get(1).getName()).as("Item 2 has expected name.").isEqualTo(newItem2.getName());
        assertThat(items.get(1).getCategory()).as("Item 2 has expected category.").isEqualTo(newItem2.getCategory());
        assertThat(items.get(1).isChecked()).as("Item 2 is not checked").isFalse();

        assertThat(items.get(2).getName()).as("Item 3 has expected name.").isEqualTo(newItem3.getName());
        assertThat(items.get(2).getCategory()).as("Item 3 has expected category.").isEqualTo(newItem3.getCategory());
        assertThat(items.get(2).isChecked()).as("Item 3 is not checked").isFalse();
    }
}
