package de.hanselmann.shoppinglist;

import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemUpdateDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;

import static org.assertj.core.api.Assertions.assertThat;

@WebServerTestWithTestUser
public class UpdateListItemEndpointTest {

    private static final String PATH = "/api/shoppinglist/{id}/item/{itemId}";

    @Autowired
    private WebTestClient webClient;

    public static void updateListItem(WebTestClient webClient,
                                      ShoppingListInfoDto list,
                                      ShoppingListItemDto item,
                                      ShoppingListItemUpdateDto update) {
        requestUpdateListItem(webClient, list, item, update).expectStatus().is2xxSuccessful();
    }

    public static WebTestClient.ResponseSpec requestUpdateListItem(WebTestClient webClient,
                                                                   ShoppingListInfoDto list,
                                                                   ShoppingListItemDto item,
                                                                   ShoppingListItemUpdateDto update) {
        return webClient.put()
                .uri(PATH, list.getId(), item.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(update)
                .exchange();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    @Sql("/InsertTestItemIntoAliceList.sql")
    public void updateNameOfExistingListItem() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);
        ShoppingListItemDto item = GetListItemsEndpointTest.getSingleListItem(client, list);

        var updateItemDto = new ShoppingListItemUpdateDto();
        updateItemDto.setName("Updated Name");
        updateListItem(client, list, item, updateItemDto);

        ShoppingListItemDto updatedItem = GetListItemsEndpointTest.getSingleListItem(client, list);
        assertThat(updatedItem.getName()).as("Item has updated name.").isEqualTo(updatedItem.getName());
        assertThat(updatedItem.getCategory()).as("Item still has no category.").isNull();
        assertThat(updatedItem.isChecked()).as("Item is still unchecked.").isFalse();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    @Sql("/InsertTestItemIntoAliceList.sql")
    public void updateCategoryOfExistingListItemWithoutCategory() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);
        ShoppingListItemDto item = GetListItemsEndpointTest.getSingleListItem(client, list);
        assertThat(item.getCategory()).as("Item has no category before update.").isNull();

        var updateItemDto = new ShoppingListItemUpdateDto();
        updateItemDto.setName(item.getName());
        updateItemDto.setCategory("Test Category");
        updateListItem(client, list, item, updateItemDto);

        ShoppingListItemDto updatedItem = GetListItemsEndpointTest.getSingleListItem(client, list);
        assertThat(updatedItem.getName()).as("Item still has old name.").isEqualTo(item.getName());
        assertThat(updatedItem.getCategory()).as("Item now has a category.").isEqualTo(updatedItem.getCategory());
        assertThat(updatedItem.isChecked()).as("Item is still unchecked.").isFalse();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    @Sql("/InsertTestItemIntoAliceList.sql")
    public void updateCategoryFailsIfOldCategoryIsNullOrBlank() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);
        ShoppingListItemDto item = GetListItemsEndpointTest.getSingleListItem(client, list);
        assertThat(item.getCategory()).as("Item has no category before update.").isNull();

        var updateItemDto = new ShoppingListItemUpdateDto();
        updateItemDto.setName(item.getName());
        updateItemDto.setCategory("Test Category");
        updateListItem(client, list, item, updateItemDto);

        ShoppingListItemDto updatedItem = GetListItemsEndpointTest.getSingleListItem(client, list);
        assertThat(updatedItem.getName()).as("Item still has old name.").isEqualTo(item.getName());
        assertThat(updatedItem.getCategory()).as("Item now has a category.").isEqualTo(updatedItem.getCategory());
        assertThat(updatedItem.isChecked()).as("Item is still unchecked.").isFalse();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    @Sql("/InsertTestItemIntoAliceList.sql")
    public void toggleItemCheckedState() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);
        ShoppingListItemDto item = GetListItemsEndpointTest.getSingleListItem(client, list);
        assertThat(item.isChecked()).as("Item is not checked before update.").isFalse();

        // Check item
        var updateItemDto = new ShoppingListItemUpdateDto();
        updateItemDto.setName(item.getName());
        updateItemDto.setChecked(true);
        updateListItem(client, list, item, updateItemDto);

        ShoppingListItemDto updatedItem = GetListItemsEndpointTest.getSingleListItem(client, list);
        assertThat(updatedItem.isChecked()).as("Item is checked after first update.").isTrue();

        updateItemDto.setChecked(false);
        updateListItem(client, list, item, updateItemDto);

        updatedItem = GetListItemsEndpointTest.getSingleListItem(client, list);
        assertThat(updatedItem.isChecked()).as("Item is unchecked after second update.").isFalse();
    }

    @Test
    @Sql("/InsertBob.sql")
    @Sql("/InsertListOfBobSharedWithAliceAsReadOnly.sql")
    @Sql("/InsertTestItemIntoBobsList.sql")
    public void updateNameOfExistingListItemFailsIfPermissionIsReadOnly() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);
        ShoppingListItemDto item = GetListItemsEndpointTest.getSingleListItem(client, list);

        var updateItemDto = new ShoppingListItemUpdateDto();
        updateItemDto.setName("Updated Name");
        requestUpdateListItem(client, list, item, updateItemDto).expectStatus().is4xxClientError();

        ShoppingListItemDto updatedItem = GetListItemsEndpointTest.getSingleListItem(client, list);
        assertThat(updatedItem.getName()).as("Item name is unchanged.").isEqualTo(item.getName());
        assertThat(updatedItem.getCategory()).as("Item still has no category.").isNull();
        assertThat(updatedItem.isChecked()).as("Item is still unchecked.").isFalse();
    }
}
