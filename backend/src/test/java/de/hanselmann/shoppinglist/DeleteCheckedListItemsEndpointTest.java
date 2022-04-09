package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;

import de.hanselmann.shoppinglist.restapi.dto.DeleteItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.testutils.ListItemBuilder;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class DeleteCheckedListItemsEndpointTest {

    private static final String PATH = "/api/shoppinglist/{id}/checkeditems";

    @Autowired
    private WebTestClient webClient;

    public static void deleteCheckedItems(WebTestClient webClient, ShoppingListInfoDto list) {
        requestDeleteCheckedItems(webClient, list.getId()).expectStatus().is2xxSuccessful();
    }

    public static void deleteCheckedItemsOfCategory(
            WebTestClient webClient,
            ShoppingListInfoDto list,
            String category) {
        requestDeleteCheckedItemsOfCategory(webClient, list.getId(), category).expectStatus().is2xxSuccessful();
    }

    public static WebTestClient.ResponseSpec requestDeleteCheckedItems(WebTestClient webClient, long listId) {
        return requestDeleteCheckedItemsOfCategory(webClient, listId, null);
    }

    public static WebTestClient.ResponseSpec requestDeleteCheckedItemsOfCategory(
            WebTestClient webClient,
            long listId,
            String category) {
        DeleteItemDto deleteDto = new DeleteItemDto();
        deleteDto.setOfCategory(category);
        return webClient.method(HttpMethod.DELETE)
                .uri(PATH, listId)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(deleteDto)
                .exchange();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void deleteAllItemsIfAllAreChecked() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").andCheckedState(true).add()
                .itemWithName("2").andCheckedState(true).add()
                .itemWithName("3").andCheckedState(true).add();

        deleteCheckedItems(client, list);

        assertThat(GetListItemsEndpointTest.getListItems(client, list)).isEmpty();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void deleteNoItemsIfNoneAreChecked() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").andCheckedState(false).add()
                .itemWithName("2").andCheckedState(false).add()
                .itemWithName("3").andCheckedState(false).add();

        deleteCheckedItems(client, list);

        List<ShoppingListItemDto> items = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(items).extracting(e -> e.getName()).containsExactly("1", "2", "3");
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void deleteOnlyCheckedItemsIfSomeAreCheckedAndOthersNot() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").andCheckedState(true).add()
                .itemWithName("2").andCheckedState(false).add()
                .itemWithName("3").andCheckedState(false).add()
                .itemWithName("4").andCheckedState(true).add()
                .itemWithName("5").andCheckedState(false).add();

        deleteCheckedItems(client, list);

        List<ShoppingListItemDto> items = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(items).extracting(e -> e.getName()).containsExactly("2", "3", "5");
    }

    @Test
    @Sql("/InsertBob.sql")
    @Sql("/InsertListOfBobSharedWithAliceAsReadOnly.sql")
    @Sql("/InsertCheckedTestItemIntoBobsList.sql")
    public void failsIfPermissionIsReadOnly() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        requestDeleteCheckedItems(client, list.getId()).expectStatus().is4xxClientError();

        assertThat(GetListItemsEndpointTest.getSingleListItem(client, list).isChecked()).isTrue();
    }

    @Test
    public void onlyRemovesCheckedItemsFromSpecifiedList() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list1 = CreateListEndpointTest.createList(client, "list1");
        ShoppingListInfoDto list2 = CreateListEndpointTest.createList(client, "list2");

        ListItemBuilder.forList(client, list1).itemWithName("1").andCheckedState(true).add();
        ListItemBuilder.forList(client, list2).itemWithName("1").andCheckedState(true).add();

        deleteCheckedItems(client, list1);

        assertThat(GetListItemsEndpointTest.getListItems(client, list1)).isEmpty();
        List<ShoppingListItemDto> list2Items = GetListItemsEndpointTest.getListItems(client, list2);
        assertThat(list2Items).extracting(e -> e.getName()).containsExactly("1");
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void deleteOnlyCheckedItemsOfSpecifiedCategory() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").andCategory("cat1").andCheckedState(false).add()
                .itemWithName("2").andCategory("cat2").andCheckedState(true).add()
                .itemWithName("3").andCategory("cat1").andCheckedState(true).add()
                .itemWithName("4").andCategory("cat3").andCheckedState(false).add()
                .itemWithName("5").andCategory("cat1").andCheckedState(true).add();

        deleteCheckedItemsOfCategory(client, list, "cat1");

        List<ShoppingListItemDto> items = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(items).extracting(e -> e.getName()).containsExactly("1", "2", "4");
    }

    @Test
    public void onlyRemovesCheckedItemsOfSpecifiedCategoryFromSpecifiedList() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list1 = CreateListEndpointTest.createList(client, "list1");
        ShoppingListInfoDto list2 = CreateListEndpointTest.createList(client, "list2");

        ListItemBuilder.forList(client, list1).itemWithName("1").andCategory("cat").andCheckedState(true).add();
        ListItemBuilder.forList(client, list2).itemWithName("1").andCategory("cat").andCheckedState(true).add();

        deleteCheckedItems(client, list1);

        assertThat(GetListItemsEndpointTest.getListItems(client, list1)).isEmpty();
        List<ShoppingListItemDto> list2Items = GetListItemsEndpointTest.getListItems(client, list2);
        assertThat(list2Items).extracting(e -> e.getName()).containsExactly("1");
    }
}
