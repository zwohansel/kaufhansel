package de.hanselmann.shoppinglist;

import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemUpdateDto;
import de.hanselmann.shoppinglist.service.AuthenticatedUserService;
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
public class UpdateListItemEndpoint {

    private static final String PATH = "/api/shoppinglist/{id}/item/{itemId}";

    @Autowired
    private WebTestClient webClient;

    @Autowired
    private ShoppingListUserRepository userRepository;

    @MockBean
    private AuthenticatedUserService authenticatedUserService;

    @BeforeEach
    public void loginTestUser() {
        when(authenticatedUserService.findCurrentUser())
                .then(mock -> userRepository.findUserByEmailAddress("test@test.test"));
    }

    @Test
    @Sql("/InsertTestList.sql")
    @Sql("/InsertTestItem.sql")
    public void updateNameOfExistingListItem() {
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(webClient);
        ShoppingListItemDto item = GetListItemsEndpointTest.getSingleListItem(webClient, list);

        var updateItemDto = new ShoppingListItemUpdateDto();
        updateItemDto.setName("Updated Name");
        webClient.put()
                .uri(PATH, list.getId(), item.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(updateItemDto)
                .exchange().expectStatus()
                .is2xxSuccessful();

        ShoppingListItemDto updatedItem = GetListItemsEndpointTest.getSingleListItem(webClient, list);
        assertThat(updatedItem.getName()).as("Item has updated name.").isEqualTo(updatedItem.getName());
        assertThat(updatedItem.getCategory()).as("Item still has no category.").isNull();
        assertThat(updatedItem.isChecked()).as("Item is still unchecked.").isFalse();
    }

    @Test
    @Sql("/InsertTestList.sql")
    @Sql("/InsertTestItem.sql")
    public void updateCategoryOfExistingListItemWithoutCategory() {
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(webClient);
        ShoppingListItemDto item = GetListItemsEndpointTest.getSingleListItem(webClient, list);
        assertThat(item.getCategory()).as("Item has no category before update.").isNull();

        var updateItemDto = new ShoppingListItemUpdateDto();
        updateItemDto.setName(item.getName());
        updateItemDto.setCategory("Test Category");
        webClient.put()
                .uri(PATH, list.getId(), item.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(updateItemDto)
                .exchange().expectStatus()
                .is2xxSuccessful();

        ShoppingListItemDto updatedItem = GetListItemsEndpointTest.getSingleListItem(webClient, list);
        assertThat(updatedItem.getName()).as("Item still has old name.").isEqualTo(item.getName());
        assertThat(updatedItem.getCategory()).as("Item now has a category.").isEqualTo(updatedItem.getCategory());
        assertThat(updatedItem.isChecked()).as("Item is still unchecked.").isFalse();
    }

    @Test
    @Sql("/InsertTestList.sql")
    @Sql("/InsertTestItem.sql")
    public void toggleItemCheckedState() {
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(webClient);
        ShoppingListItemDto item = GetListItemsEndpointTest.getSingleListItem(webClient, list);
        assertThat(item.isChecked()).as("Item is not checked before update.").isFalse();

        // Check item
        var updateItemDto = new ShoppingListItemUpdateDto();
        updateItemDto.setName(item.getName());
        updateItemDto.setChecked(true);
        webClient.put()
                .uri(PATH, list.getId(), item.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(updateItemDto)
                .exchange().expectStatus()
                .is2xxSuccessful();

        ShoppingListItemDto updatedItem = GetListItemsEndpointTest.getSingleListItem(webClient, list);
        assertThat(updatedItem.isChecked()).as("Item is checked after first update.").isTrue();

        updateItemDto.setChecked(false);
        webClient.put()
                .uri(PATH, list.getId(), item.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(updateItemDto)
                .exchange().expectStatus()
                .is2xxSuccessful();

        updatedItem = GetListItemsEndpointTest.getSingleListItem(webClient, list);
        assertThat(updatedItem.isChecked()).as("Item is unchecked after second update.").isFalse();
    }
}
