package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;

import de.hanselmann.shoppinglist.restapi.dto.MoveShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.testutils.ListItemBuilder;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class MoveListItemEndpointTest {

    private static final String PATH = "/api/shoppinglist/{id}/moveitem";

    @Autowired
    private WebTestClient webClient;

    public static void moveListItem(WebTestClient webClient,
            ShoppingListInfoDto list,
            MoveShoppingListItemDto moveItem) {
        requestMoveListItem(webClient, list, moveItem).expectStatus().is2xxSuccessful();
    }

    public static WebTestClient.ResponseSpec requestMoveListItem(WebTestClient webClient,
            ShoppingListInfoDto list,
            MoveShoppingListItemDto moveItem) {
        return webClient.put()
                .uri(PATH, list.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(moveItem)
                .exchange();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void moveFirstToLast() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").add()
                .itemWithName("2").add()
                .itemWithName("3").add()
                .itemWithName("4").add()
                .itemWithName("5").add();

        List<ShoppingListItemDto> itemsBeforeReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsBeforeReorder).extracting(e -> e.getName()).containsExactly("1", "2", "3", "4", "5");

        MoveShoppingListItemDto moveItem = new MoveShoppingListItemDto();
        moveItem.setItemId(itemsBeforeReorder.get(0).getId()); // item 1
        moveItem.setTargetIndex(4); // move to last position
        moveListItem(client, list, moveItem);

        List<ShoppingListItemDto> itemsAfterReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsAfterReorder).extracting(e -> e.getName()).containsExactly("2", "3", "4", "5", "1");
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void moveLastToFirst() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").add()
                .itemWithName("2").add()
                .itemWithName("3").add()
                .itemWithName("4").add()
                .itemWithName("5").add();

        List<ShoppingListItemDto> itemsBeforeReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsBeforeReorder).extracting(e -> e.getName()).containsExactly("1", "2", "3", "4", "5");

        MoveShoppingListItemDto moveItem = new MoveShoppingListItemDto();
        moveItem.setItemId(itemsBeforeReorder.get(4).getId()); // item 5
        moveItem.setTargetIndex(0); // move to first position
        moveListItem(client, list, moveItem);

        List<ShoppingListItemDto> itemsAfterReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsAfterReorder).extracting(e -> e.getName()).containsExactly("5", "1", "2", "3", "4");
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void moveSecondLastToSecondFirst() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").add()
                .itemWithName("2").add()
                .itemWithName("3").add()
                .itemWithName("4").add()
                .itemWithName("5").add();

        List<ShoppingListItemDto> itemsBeforeReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsBeforeReorder).extracting(e -> e.getName()).containsExactly("1", "2", "3", "4", "5");

        MoveShoppingListItemDto moveItem = new MoveShoppingListItemDto();
        moveItem.setItemId(itemsBeforeReorder.get(3).getId()); // item 4
        moveItem.setTargetIndex(1); // move to second position
        moveListItem(client, list, moveItem);

        List<ShoppingListItemDto> itemsAfterReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsAfterReorder).extracting(e -> e.getName()).containsExactly("1", "4", "2", "3", "5");
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void moveSecondFirstToSecondLast() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").add()
                .itemWithName("2").add()
                .itemWithName("3").add()
                .itemWithName("4").add()
                .itemWithName("5").add();

        List<ShoppingListItemDto> itemsBeforeReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsBeforeReorder).extracting(e -> e.getName()).containsExactly("1", "2", "3", "4", "5");

        MoveShoppingListItemDto moveItem = new MoveShoppingListItemDto();
        moveItem.setItemId(itemsBeforeReorder.get(1).getId()); // item 2
        moveItem.setTargetIndex(3); // move to second last position
        moveListItem(client, list, moveItem);

        List<ShoppingListItemDto> itemsAfterReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsAfterReorder).extracting(e -> e.getName()).containsExactly("1", "3", "4", "2", "5");
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void swapFirstAndSecond() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").add()
                .itemWithName("2").add()
                .itemWithName("3").add()
                .itemWithName("4").add()
                .itemWithName("5").add();

        List<ShoppingListItemDto> itemsBeforeReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsBeforeReorder).extracting(e -> e.getName()).containsExactly("1", "2", "3", "4", "5");

        MoveShoppingListItemDto moveItem = new MoveShoppingListItemDto();
        moveItem.setItemId(itemsBeforeReorder.get(0).getId()); // item 1
        moveItem.setTargetIndex(1); // move to second position
        moveListItem(client, list, moveItem);

        List<ShoppingListItemDto> itemsAfterReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsAfterReorder).extracting(e -> e.getName()).containsExactly("2", "1", "3", "4", "5");
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void swapSecondAndFirst() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").add()
                .itemWithName("2").add()
                .itemWithName("3").add()
                .itemWithName("4").add()
                .itemWithName("5").add();

        List<ShoppingListItemDto> itemsBeforeReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsBeforeReorder).extracting(e -> e.getName()).containsExactly("1", "2", "3", "4", "5");

        MoveShoppingListItemDto moveItem = new MoveShoppingListItemDto();
        moveItem.setItemId(itemsBeforeReorder.get(1).getId()); // item 2
        moveItem.setTargetIndex(0); // move to first position
        moveListItem(client, list, moveItem);

        List<ShoppingListItemDto> itemsAfterReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsAfterReorder).extracting(e -> e.getName()).containsExactly("2", "1", "3", "4", "5");
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void swapSecondAndThird() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").add()
                .itemWithName("2").add()
                .itemWithName("3").add()
                .itemWithName("4").add()
                .itemWithName("5").add();

        List<ShoppingListItemDto> itemsBeforeReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsBeforeReorder).extracting(e -> e.getName()).containsExactly("1", "2", "3", "4", "5");

        MoveShoppingListItemDto moveItem = new MoveShoppingListItemDto();
        moveItem.setItemId(itemsBeforeReorder.get(1).getId()); // item 2
        moveItem.setTargetIndex(2); // move to third position
        moveListItem(client, list, moveItem);

        List<ShoppingListItemDto> itemsAfterReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsAfterReorder).extracting(e -> e.getName()).containsExactly("1", "3", "2", "4", "5");
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void swapThirdAndSecond() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").add()
                .itemWithName("2").add()
                .itemWithName("3").add()
                .itemWithName("4").add()
                .itemWithName("5").add();

        List<ShoppingListItemDto> itemsBeforeReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsBeforeReorder).extracting(e -> e.getName()).containsExactly("1", "2", "3", "4", "5");

        MoveShoppingListItemDto moveItem = new MoveShoppingListItemDto();
        moveItem.setItemId(itemsBeforeReorder.get(2).getId()); // item 3
        moveItem.setTargetIndex(1); // move to second position
        moveListItem(client, list, moveItem);

        List<ShoppingListItemDto> itemsAfterReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsAfterReorder).extracting(e -> e.getName()).containsExactly("1", "3", "2", "4", "5");
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void movingElementBehindTheEndOfTheListMovesItToLastPosition() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").add()
                .itemWithName("2").add()
                .itemWithName("3").add()
                .itemWithName("4").add()
                .itemWithName("5").add();

        List<ShoppingListItemDto> itemsBeforeReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsBeforeReorder).extracting(e -> e.getName()).containsExactly("1", "2", "3", "4", "5");

        MoveShoppingListItemDto moveItem = new MoveShoppingListItemDto();
        moveItem.setItemId(itemsBeforeReorder.get(0).getId()); // item 1
        moveItem.setTargetIndex(100);
        moveListItem(client, list, moveItem);

        List<ShoppingListItemDto> itemsAfterReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsAfterReorder).extracting(e -> e.getName()).containsExactly("2", "3", "4", "5", "1");
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void movingLastElementBehindTheEndOfTheListChangesNothing() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").add()
                .itemWithName("2").add()
                .itemWithName("3").add()
                .itemWithName("4").add()
                .itemWithName("5").add();

        List<ShoppingListItemDto> itemsBeforeReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsBeforeReorder).extracting(e -> e.getName()).containsExactly("1", "2", "3", "4", "5");

        MoveShoppingListItemDto moveItem = new MoveShoppingListItemDto();
        moveItem.setItemId(itemsBeforeReorder.get(4).getId()); // item 5
        moveItem.setTargetIndex(100);
        moveListItem(client, list, moveItem);

        List<ShoppingListItemDto> itemsAfterReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsAfterReorder).extracting(e -> e.getName()).containsExactly("1", "2", "3", "4", "5");
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void movingElementToNegativIndexFails() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        ListItemBuilder.forList(client, list)
                .itemWithName("1").add()
                .itemWithName("2").add()
                .itemWithName("3").add()
                .itemWithName("4").add()
                .itemWithName("5").add();

        List<ShoppingListItemDto> itemsBeforeReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsBeforeReorder).extracting(e -> e.getName()).containsExactly("1", "2", "3", "4", "5");

        MoveShoppingListItemDto moveItem = new MoveShoppingListItemDto();
        moveItem.setItemId(itemsBeforeReorder.get(4).getId()); // item 5
        moveItem.setTargetIndex(-1);
        requestMoveListItem(client, list, moveItem).expectStatus().is4xxClientError();

        List<ShoppingListItemDto> itemsAfterReorder = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(itemsAfterReorder).extracting(e -> e.getName()).containsExactly("1", "2", "3", "4", "5");
    }
}
