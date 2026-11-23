package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.client.RestTestClient;
import org.springframework.test.web.servlet.client.RestTestClient.ResponseSpec;

import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class GetListItemsEndpointTest {
    private static final String PATH = "/api/shoppinglist/{id}";
    private static final ParameterizedTypeReference<List<ShoppingListItemDto>> ITEM_LIST = new ParameterizedTypeReference<>() {
    };

    @Autowired
    private RestTestClient webClient;

    public static List<ShoppingListItemDto> getListItems(RestTestClient webClient, ShoppingListInfoDto list) {
        return requestListItems(webClient, list).expectStatus()
                .is2xxSuccessful()
                .expectBody(ITEM_LIST)
                .returnResult()
                .getResponseBody();
    }

    public static ResponseSpec requestListItems(RestTestClient webClient,
            ShoppingListInfoDto list) {
        return webClient.get()
                .uri(PATH, list.getId())
                .exchange();
    }

    public static ShoppingListItemDto getSingleListItem(RestTestClient webClient, ShoppingListInfoDto list) {
        return requestListItems(webClient, list).expectStatus()
                .is2xxSuccessful()
                .expectBody(ITEM_LIST)
                .value(items -> assertThat(items).hasSize(1))
                .returnResult()
                .getResponseBody()
                .get(0);
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void getShoppingListItemsReturnsEmptyListIfNoItemsArePresent() {
        RestTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);
        client.get()
                .uri(PATH, list.getId())
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBody(ITEM_LIST)
                .value(items -> assertThat(items).isEmpty());
    }

    @Test
    @Sql("/InsertAliceList.sql")
    @Sql("/InsertTestItemIntoAliceList.sql")
    public void getExistingShoppingListItem() {
        RestTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);
        List<ShoppingListItemDto> items = getListItems(client, list);
        assertThat(items).as(PATH + " returns existing item").singleElement();
        assertThat(items.get(0).getName()).as("Item has expected name.").isEqualTo("Test Item");
        assertThat(items.get(0).getCategory()).as("Item has no category.").isNull();
        assertThat(items.get(0).isChecked()).as("Item is not checked").isFalse();
    }
}
