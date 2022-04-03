package de.hanselmann.shoppinglist;

import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.restapi.dto.*;
import de.hanselmann.shoppinglist.testutils.ListItemBuilder;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@WebServerTestWithTestUser
public class UncheckListItemsEndpointTest {

    private static final String PATH = "/api/shoppinglist/{id}/uncheckitems";

    @Autowired
    private WebTestClient webClient;

    public static void uncheckAllItems(WebTestClient webClient,
                                       ShoppingListInfoDto list,
                                       UncheckShoppingListItemsDto uncheckDto) {
        webClient.put()
                .uri(PATH, list.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(uncheckDto)
                .exchange()
                .expectStatus()
                .is2xxSuccessful();
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void allItemsAreUncheckedIfNotCategoryIsSpecified() {
        WebTestClient client = LoginTest.loggedInClient(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        // Create checked items, each with a different category
        ListItemBuilder.forList(client, list)
                .itemWithName("Item 1").andCheckedState(true).add()
                .itemWithName("Item 2").andCategory("Category 1").andCheckedState(true).add()
                .itemWithName("Item 3").andCategory("Category 1").andCheckedState(true).add()
                .itemWithName("Item 4").andCategory("Category 1").andCheckedState(true).add();

        UncheckShoppingListItemsDto uncheckDto = new UncheckShoppingListItemsDto();
        uncheckAllItems(client, list, uncheckDto);

        List<ShoppingListItemDto> items = GetListItemsEndpointTest.getListItems(client, list);
        assertThat(items).isNotEmpty().allSatisfy(item -> {
            assertThat(item.isChecked()).isFalse();
        });
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void onlyItemsOfTheSpecifiedCategoryAreUnchecked() {
        WebTestClient client = LoginTest.loggedInClient(webClient);
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
        uncheckAllItems(client, list, uncheckDto);

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
