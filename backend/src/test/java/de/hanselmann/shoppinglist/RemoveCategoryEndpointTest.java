package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;

import de.hanselmann.shoppinglist.restapi.dto.RemoveShoppingListCategoryDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.testutils.ListItemBuilder;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class RemoveCategoryEndpointTest {
    private static final String PATH = "/api/shoppinglist/{id}/removecategory";

    @Autowired
    private WebTestClient webClient;

    public static void removeCategory(WebTestClient webClient,
            ShoppingListInfoDto list,
            RemoveShoppingListCategoryDto removeDto) {
        webClient.put()
                .uri(PATH, list.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(removeDto)
                .exchange()
                .expectStatus()
                .is2xxSuccessful();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void removeAllCategoriesIfNoCategoryIsSpecified() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        // Create list items with different categories
        ListItemBuilder.forList(client, list)
                .itemWithName("Item 1").andCategory("Category 1").add()
                .itemWithName("Item 2").andCategory("Category 2").add()
                .itemWithName("Item 3").andCategory("Category 3").add()
                .itemWithName("Item 4").andCategory("Category 4").add();

        RemoveShoppingListCategoryDto removeDto = new RemoveShoppingListCategoryDto();
        removeCategory(client, list, removeDto);

        assertThat(GetListItemsEndpointTest.getListItems(client, list))
                .isNotEmpty()
                .allSatisfy(item -> assertThat(item.getCategory()).isNull());
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void removesOnlySpecifiedCategory() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        final String categoryOne = "Category 1";
        final String categoryTwo = "Category 2";

        // Create list items for both categories
        ListItemBuilder.forList(client, list)
                .itemWithName("Item 1").andCategory(categoryOne).add()
                .itemWithName("Item 2").andCategory(categoryOne).add()
                .itemWithName("Item 3").andCategory(categoryTwo).add()
                .itemWithName("Item 4").andCategory(categoryTwo).add();

        // Remove the second category
        RemoveShoppingListCategoryDto removeDto = new RemoveShoppingListCategoryDto();
        removeDto.setCategory(categoryTwo);
        removeCategory(client, list, removeDto);

        assertThat(GetListItemsEndpointTest.getListItems(client, list))
                .filteredOn(ShoppingListItemDto::getCategory, categoryOne)
                .isNotEmpty()
                .allSatisfy(item -> assertThat(item.getCategory()).isEqualTo(categoryOne));

        assertThat(GetListItemsEndpointTest.getListItems(client, list))
                .filteredOn(ShoppingListItemDto::getCategory, null)
                .isNotEmpty()
                .allSatisfy(item -> assertThat(item.getCategory()).isNull());
    }

}
