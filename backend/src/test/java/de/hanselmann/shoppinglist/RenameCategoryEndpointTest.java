package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;

import de.hanselmann.shoppinglist.restapi.dto.RenameShoppingListCategoryDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.testutils.ListItemBuilder;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class RenameCategoryEndpointTest {
    private static final String PATH = "/api/shoppinglist/{id}/renamecategory";

    @Autowired
    private WebTestClient webClient;

    public static void renameCategory(WebTestClient webClient, ShoppingListInfoDto list,
            RenameShoppingListCategoryDto renameDto) {
        webClient.put()
                .uri(PATH, list.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(renameDto)
                .exchange()
                .expectStatus()
                .is2xxSuccessful();
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void renamesCategoryIfNewCategoryNameIsNotPresent() {
        WebTestClient client = LoginTest.loggedInClient(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        final String oldCategoryName = "OldName";
        final String newCategoryName = "NewName";

        ListItemBuilder.forList(client, list)
                .itemWithName("Item").andCategory(oldCategoryName).add();

        RenameShoppingListCategoryDto renameDto = new RenameShoppingListCategoryDto();
        renameDto.setOldCategory(oldCategoryName);
        renameDto.setNewCategory(newCategoryName);
        renameCategory(client, list, renameDto);

        assertThat(GetListItemsEndpointTest.getSingleListItem(client, list).getCategory()).isEqualTo(newCategoryName);
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void mergeCategoryIfNewCategoryNameIsAlreadyPresent() {
        WebTestClient client = LoginTest.loggedInClient(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        final String oldCategoryName = "OldName";
        final String newCategoryName = "NewName";
        final String finalCategoryName = "Foo";

        ListItemBuilder.forList(client, list)
                .itemWithName("Item 1").andCategory(oldCategoryName).add()
                .itemWithName("Item 2").andCategory(newCategoryName).add();

        RenameShoppingListCategoryDto renameDto = new RenameShoppingListCategoryDto();
        renameDto.setOldCategory(oldCategoryName);
        renameDto.setNewCategory(newCategoryName);
        renameCategory(client, list, renameDto);

        assertThat(GetListItemsEndpointTest.getListItems(client, list))
                .isNotEmpty()
                .allSatisfy(item -> assertThat(item.getCategory()).isEqualTo(newCategoryName));

        // If we rename again all items should belong to the final category
        renameDto.setOldCategory(newCategoryName);
        renameDto.setNewCategory(finalCategoryName);
        renameCategory(client, list, renameDto);

        assertThat(GetListItemsEndpointTest.getListItems(client, list))
                .isNotEmpty()
                .allSatisfy(item -> assertThat(item.getCategory()).isEqualTo(finalCategoryName));
    }
}
