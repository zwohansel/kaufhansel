package de.hanselmann.shoppinglist;

import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.restapi.dto.RenameShoppingListCategoryDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.service.AuthenticatedUserService;
import de.hanselmann.shoppinglist.testutils.ListItemBuilder;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@WebServerTestWithTestUser
public class RenameCategoryEndpointTest {
    private static final String PATH = "/api/shoppinglist/{id}/renamecategory";

    @Autowired
    private WebTestClient webClient;

    @Autowired
    private ShoppingListUserRepository userRepository;

    @MockBean
    private AuthenticatedUserService authenticatedUserService;

    public static void renameCategory(WebTestClient webClient, ShoppingListInfoDto list, RenameShoppingListCategoryDto renameDto) {
        webClient.put()
                .uri(PATH, list.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(renameDto)
                .exchange()
                .expectStatus()
                .is2xxSuccessful();
    }

    @BeforeEach
    public void loginTestUser() {
        when(authenticatedUserService.findCurrentUser())
                .then(mock -> userRepository.findUserByEmailAddress("test@test.test"));
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void renamesCategoryIfNewCategoryNameIsNotPresent() {
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(webClient);

        final String oldCategoryName = "OldName";
        final String newCategoryName = "NewName";

        ListItemBuilder.forList(webClient, list)
                .itemWithName("Item").andCategory(oldCategoryName).add();

        RenameShoppingListCategoryDto renameDto = new RenameShoppingListCategoryDto();
        renameDto.setOldCategory(oldCategoryName);
        renameDto.setNewCategory(newCategoryName);
        renameCategory(webClient, list, renameDto);

        assertThat(GetListItemsEndpointTest.getSingleListItem(webClient, list).getCategory()).isEqualTo(newCategoryName);
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void mergeCategoryIfNewCategoryNameIsAlreadyPresent() {
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(webClient);

        final String oldCategoryName = "OldName";
        final String newCategoryName = "NewName";
        final String finalCategoryName = "Foo";

        ListItemBuilder.forList(webClient, list)
                .itemWithName("Item 1").andCategory(oldCategoryName).add()
                .itemWithName("Item 2").andCategory(newCategoryName).add();

        RenameShoppingListCategoryDto renameDto = new RenameShoppingListCategoryDto();
        renameDto.setOldCategory(oldCategoryName);
        renameDto.setNewCategory(newCategoryName);
        renameCategory(webClient, list, renameDto);

        assertThat(GetListItemsEndpointTest.getListItems(webClient, list))
                .isNotEmpty()
                .allSatisfy(item -> assertThat(item.getCategory()).isEqualTo(newCategoryName));

        // If we rename again all items should belong to the final category
        renameDto.setOldCategory(newCategoryName);
        renameDto.setNewCategory(finalCategoryName);
        renameCategory(webClient, list, renameDto);

        assertThat(GetListItemsEndpointTest.getListItems(webClient, list))
                .isNotEmpty()
                .allSatisfy(item -> assertThat(item.getCategory()).isEqualTo(finalCategoryName));
    }
}
