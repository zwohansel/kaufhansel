package de.hanselmann.shoppinglist;

import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.restapi.dto.RemoveShoppingListCategoryDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
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
public class RemoveCategoryEndpointTest {
    private static final String PATH = "/api/shoppinglist/{id}/removecategory";

    @Autowired
    private WebTestClient webClient;

    @Autowired
    private ShoppingListUserRepository userRepository;

    @MockBean
    private AuthenticatedUserService authenticatedUserService;

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

    @BeforeEach
    public void loginTestUser() {
        when(authenticatedUserService.findCurrentUser())
                .then(mock -> userRepository.findUserByEmailAddress("test@test.test"));
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void removeAllCategoriesIfNoCategoryIsSpecified() {
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(webClient);

        // Create list items with different categories
        ListItemBuilder.forList(webClient, list)
                .itemWithName("Item 1").andCategory("Category 1").add()
                .itemWithName("Item 2").andCategory("Category 2").add()
                .itemWithName("Item 3").andCategory("Category 3").add()
                .itemWithName("Item 4").andCategory("Category 4").add();

        RemoveShoppingListCategoryDto removeDto = new RemoveShoppingListCategoryDto();
        removeCategory(webClient, list, removeDto);

        assertThat(GetListItemsEndpointTest.getListItems(webClient, list))
                .isNotEmpty()
                .allSatisfy(item -> assertThat(item.getCategory()).isNull());
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void removesOnlySpecifiedCategory() {
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(webClient);

        final String categoryOne = "Category 1";
        final String categoryTwo = "Category 2";

        // Create list items for both categories
        ListItemBuilder.forList(webClient, list)
                .itemWithName("Item 1").andCategory(categoryOne).add()
                .itemWithName("Item 2").andCategory(categoryOne).add()
                .itemWithName("Item 3").andCategory(categoryTwo).add()
                .itemWithName("Item 4").andCategory(categoryTwo).add();

        // Remove the second category
        RemoveShoppingListCategoryDto removeDto = new RemoveShoppingListCategoryDto();
        removeDto.setCategory(categoryTwo);
        removeCategory(webClient, list, removeDto);

        assertThat(GetListItemsEndpointTest.getListItems(webClient, list))
                .filteredOn(ShoppingListItemDto::getCategory, categoryOne)
                .isNotEmpty()
                .allSatisfy(item -> assertThat(item.getCategory()).isEqualTo(categoryOne));

        assertThat(GetListItemsEndpointTest.getListItems(webClient, list))
                .filteredOn(ShoppingListItemDto::getCategory, null)
                .isNotEmpty()
                .allSatisfy(item -> assertThat(item.getCategory()).isNull());
    }


}
