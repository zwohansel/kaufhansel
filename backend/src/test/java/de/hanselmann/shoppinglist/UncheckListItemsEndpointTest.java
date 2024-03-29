package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.springframework.test.web.reactive.server.WebTestClient.ResponseSpec;

import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.UncheckShoppingListItemsDto;
import de.hanselmann.shoppinglist.testutils.ListItemBuilder;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class UncheckListItemsEndpointTest {

    private static final String PATH = "/api/shoppinglist/{id}/uncheckitems";

    @Autowired
    private WebTestClient webClient;

    public static void uncheckItems(WebTestClient webClient,
            ShoppingListInfoDto list,
            UncheckShoppingListItemsDto uncheckDto) {
        requestUncheckItems(webClient, list, uncheckDto)
                .expectStatus()
                .is2xxSuccessful();
    }

    public static ResponseSpec requestUncheckItems(WebTestClient webClient,
            ShoppingListInfoDto list,
            UncheckShoppingListItemsDto uncheckDto) {
        return webClient.put()
                .uri(PATH, list.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(uncheckDto)
                .exchange();
    }

    public static ResponseSpec requestUncheckAllItems(WebTestClient webClient, ShoppingListInfoDto list) {
        return requestUncheckItems(webClient, list, new UncheckShoppingListItemsDto());
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void allItemsAreUncheckedIfNotCategoryIsSpecified() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        // Create checked items, each with a different category
        ListItemBuilder.forList(client, list)
                .itemWithName("Item 1").andCheckedState(true).add()
                .itemWithName("Item 2").andCategory("Category 1").andCheckedState(true).add()
                .itemWithName("Item 3").andCategory("Category 1").andCheckedState(true).add()
                .itemWithName("Item 4").andCategory("Category 1").andCheckedState(true).add();

        UncheckShoppingListItemsDto uncheckDto = new UncheckShoppingListItemsDto();
        uncheckItems(client, list, uncheckDto);

        List<ShoppingListItemDto> items = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(items).isNotEmpty().allSatisfy(item -> {
            assertThat(item.isChecked()).isFalse();
        });
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void onlyItemsOfTheSpecifiedCategoryAreUnchecked() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        final String categoryOne = "Category 1";
        final String categoryTwo = "Category 2";

        // Create checked items for both categories
        ListItemBuilder.forList(client, list)
                .itemWithName("Item 1").andCategory(categoryOne).andCheckedState(true).add()
                .itemWithName("Item 2").andCategory(categoryOne).andCheckedState(true).add()
                .itemWithName("Item 3").andCategory(categoryTwo).andCheckedState(true).add()
                .itemWithName("Item 4").andCategory(categoryTwo).andCheckedState(true).add();

        // Uncheck only items of the second category
        UncheckShoppingListItemsDto uncheckDto = new UncheckShoppingListItemsDto();
        uncheckDto.setCategory(categoryTwo);
        uncheckItems(client, list, uncheckDto);

        List<ShoppingListItemDto> items = GetListItemsEndpointTest.getListItems(client, list);
        // Assert that all items of the first category are still checked
        assertThat(items).filteredOn(ShoppingListItemDto::getCategory, categoryOne).isNotEmpty().allSatisfy(item -> {
            assertThat(item.isChecked()).isTrue();
        });
        // Assert that all items of the second category are unchecked
        assertThat(items).filteredOn(ShoppingListItemDto::getCategory, categoryTwo).isNotEmpty().allSatisfy(item -> {
            assertThat(item.isChecked()).isFalse();
        });
    }

}
