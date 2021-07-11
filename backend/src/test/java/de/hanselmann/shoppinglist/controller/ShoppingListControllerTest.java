package de.hanselmann.shoppinglist.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.test.context.jdbc.SqlMergeMode.MergeMode;
import org.springframework.test.web.reactive.server.WebTestClient;

import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListDto;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemUpdateDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListPermissionsDto;
import de.hanselmann.shoppinglist.service.AuthenticatedUserService;
import de.hanselmann.shoppinglist.testutils.CleanDatabaseExtension;

@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@ExtendWith(CleanDatabaseExtension.class)
@TestPropertySource(locations = "classpath:application-test.properties")
@ActiveProfiles("test")
@Sql("/InsertTestUser.sql")
@SqlMergeMode(MergeMode.MERGE) // Execute method level @Sql after call level @Sql
public class ShoppingListControllerTest {
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
    public void shoppingListEndpointFailsIfUserNotAuthenticated() {
        when(authenticatedUserService.findCurrentUser()).thenReturn(Optional.empty());
        webClient.get()
                .uri("/api/shoppinglists")
                .exchange()
                .expectStatus()
                .is5xxServerError();
    }

    @Test
    public void shoppingListEndpointReturnsEmptyListIfUserHasNoLists() {
        webClient.get()
                .uri("/api/shoppinglists")
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class)
                .hasSize(0);
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void shoppingListEndpointReturnsExistingList() {
        List<ShoppingListInfoDto> lists = webClient.get()
                .uri("/api/shoppinglists")
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class)
                .returnResult()
                .getResponseBody();

        assertThat(lists).as("Response body contains single list info object").singleElement();
        ShoppingListInfoDto listInfo = lists.get(0);
        assertThat(listInfo.getName()).isEqualTo("Test List");
        assertThat(listInfo.getOtherUsers()).as("No other user can access the created list").isEmpty();

        ShoppingListPermissionsDto permissions = listInfo.getPermissions();
        assertThat(permissions).as("List info has user permissions").isNotNull();
        assertThat(permissions.getRole()).as("User has admin role").isEqualTo(ShoppingListRole.ADMIN);
        assertThat(permissions.isCanCheckItems()).as("User has the permission to check items").isTrue();
        assertThat(permissions.isCanEditItems()).as("User has the permission to edit items").isTrue();
        assertThat(permissions.isCanEditList()).as("User has the permission to edit the list").isTrue();
    }

    @Test
    public void createsNewList() {
        final String newListName = "New Shopping List";
        var newListDto = new NewShoppingListDto();
        newListDto.setName(newListName);

        ShoppingListInfoDto createdList = webClient.post()
                .uri("/api/shoppinglist")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(newListDto)
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBody(ShoppingListInfoDto.class)
                .returnResult().getResponseBody();

        assertThat(createdList.getName()).isEqualTo(newListName);
        assertThat(createdList.getOtherUsers()).as("No other user can access the created list").isEmpty();

        ShoppingListPermissionsDto permissions = createdList.getPermissions();
        assertThat(permissions).as("Creation response has permissions").isNotNull();
        assertThat(permissions.getRole()).as("Creator has admin role").isEqualTo(ShoppingListRole.ADMIN);
        assertThat(permissions.isCanCheckItems()).as("Creator has the permission to check items").isTrue();
        assertThat(permissions.isCanEditItems()).as("Creator has the permission to edit items").isTrue();
        assertThat(permissions.isCanEditList()).as("Creator has the permission to edit the list").isTrue();

        List<ShoppingListInfoDto> lists = webClient.get()
                .uri("/api/shoppinglists")
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class)
                .returnResult()
                .getResponseBody();

        assertThat(lists).as("/shoppinglist returns created list").singleElement();
        assertThat(lists.get(0).getId()).as("id of list returned by /shoppinglist matches id of created list")
                .isEqualTo(createdList.getId());
    }

    @Test
    public void postToShoppingListReturnsBadRequestIfNoNameIsGiven() {
        webClient.post()
                .uri("/api/shoppinglist")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(new NewShoppingListDto())
                .exchange()
                .expectStatus()
                .isBadRequest();

        // Check that no list has been created
        webClient.get()
                .uri("/api/shoppinglists")
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class)
                .hasSize(0);
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void deleteShoppingListDeletesExistingList() {
        List<ShoppingListInfoDto> lists = webClient.get()
                .uri("/api/shoppinglists")
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class)
                .hasSize(1)
                .returnResult()
                .getResponseBody();

        webClient.delete()
                .uri("/api/shoppinglist/{id}", lists.get(0).getId())
                .exchange()
                .expectStatus()
                .is2xxSuccessful();

        webClient.get()
                .uri("/api/shoppinglists")
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class)
                .hasSize(0);
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void getShoppingListItemsReturnsEmptyListIfNoItemsArePresent() {
        ShoppingListInfoDto list = webClient.get()
                .uri("/api/shoppinglists")
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class)
                .hasSize(1)
                .returnResult()
                .getResponseBody()
                .get(0);
        webClient.get()
                .uri("/api/shoppinglist/{id}", list.getId())
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListItemDto.class)
                .hasSize(0);
    }

    @Test
    @Sql("/InsertTestList.sql")
    @Sql("/InsertTestItem.sql")
    public void getExistingShoppingListItem() {
        ShoppingListInfoDto list = webClient.get()
                .uri("/api/shoppinglists")
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class)
                .hasSize(1)
                .returnResult()
                .getResponseBody()
                .get(0);
        List<ShoppingListItemDto> items = webClient.get()
                .uri("/api/shoppinglist/{id}", list.getId())
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListItemDto.class)
                .returnResult()
                .getResponseBody();
        assertThat(items).as("/shoppinglist/{id} returns existing item").singleElement();
        assertThat(items.get(0).getName()).as("Item has expected name.").isEqualTo("Test Item");
        assertThat(items.get(0).getCategory()).as("Item has no category.").isNull();
        assertThat(items.get(0).isChecked()).as("Item is not checked").isFalse();
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void createNewShoppingListItemWithoutCategory() {
        ShoppingListInfoDto list = webClient.get()
                .uri("/api/shoppinglists")
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class)
                .hasSize(1)
                .returnResult()
                .getResponseBody()
                .get(0);

        var newItem = new NewShoppingListItemDto();
        newItem.setName("New Item");

        ShoppingListItemDto createdItem = webClient.post()
                .uri("/api/shoppinglist/{id}", list.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(newItem)
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBody(ShoppingListItemDto.class)
                .returnResult()
                .getResponseBody();

        assertThat(createdItem.getName()).as("Item has expected name.").isEqualTo(newItem.getName());
        assertThat(createdItem.getCategory()).as("Item has no category.").isNull();
        assertThat(createdItem.isChecked()).as("Item is not checked").isFalse();

        List<ShoppingListItemDto> items = webClient.get()
                .uri("/api/shoppinglist/{id}", list.getId())
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListItemDto.class)
                .returnResult()
                .getResponseBody();

        assertThat(items).as("/shoppinglist/{id} returns created item").singleElement();
        assertThat(items.get(0).getName()).as("Item has expected name.").isEqualTo(newItem.getName());
        assertThat(items.get(0).getCategory()).as("Item has no category.").isNull();
        assertThat(items.get(0).isChecked()).as("Item is not checked").isFalse();
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void createNewShoppingListItemWithCategory() {
        ShoppingListInfoDto list = webClient.get()
                .uri("/api/shoppinglists")
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class)
                .hasSize(1)
                .returnResult()
                .getResponseBody()
                .get(0);

        var newItem = new NewShoppingListItemDto();
        newItem.setName("New Item");
        newItem.setCategory("New Category");

        ShoppingListItemDto createdItem = webClient.post()
                .uri("/api/shoppinglist/{id}", list.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(newItem)
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBody(ShoppingListItemDto.class)
                .returnResult()
                .getResponseBody();

        assertThat(createdItem.getName()).as("Item has expected name.").isEqualTo(newItem.getName());
        assertThat(createdItem.getCategory()).as("Item has expected category.").isEqualTo(newItem.getCategory());
        assertThat(createdItem.isChecked()).as("Item is not checked").isFalse();

        List<ShoppingListItemDto> items = webClient.get()
                .uri("/api/shoppinglist/{id}", list.getId())
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListItemDto.class)
                .returnResult()
                .getResponseBody();

        assertThat(items).as("/shoppinglist/{id} returns created item").singleElement();
        assertThat(items.get(0).getName()).as("Item has expected name.").isEqualTo(newItem.getName());
        assertThat(items.get(0).getCategory()).as("Item has expected category.").isEqualTo(newItem.getCategory());
        assertThat(items.get(0).isChecked()).as("Item is not checked").isFalse();
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void shoppingListItemsAreReturnedInTheOrderOfCreation() {
        ShoppingListInfoDto list = webClient.get()
                .uri("/api/shoppinglists")
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class)
                .hasSize(1)
                .returnResult()
                .getResponseBody()
                .get(0);

        var newItem1 = new NewShoppingListItemDto();
        newItem1.setName("Item 1");
        newItem1.setCategory("Category I");

        var newItem2 = new NewShoppingListItemDto();
        newItem2.setName("Item 2");
        newItem2.setCategory("Category I");

        var newItem3 = new NewShoppingListItemDto();
        newItem3.setName("Item 3");
        newItem3.setCategory("Category II");

        webClient.post()
                .uri("/api/shoppinglist/{id}", list.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(newItem1)
                .exchange()
                .expectStatus()
                .is2xxSuccessful();

        webClient.post()
                .uri("/api/shoppinglist/{id}", list.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(newItem2)
                .exchange()
                .expectStatus()
                .is2xxSuccessful();

        webClient.post()
                .uri("/api/shoppinglist/{id}", list.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(newItem3)
                .exchange()
                .expectStatus()
                .is2xxSuccessful();

        List<ShoppingListItemDto> items = webClient.get()
                .uri("/api/shoppinglist/{id}", list.getId())
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListItemDto.class)
                .returnResult()
                .getResponseBody();

        assertThat(items).as("/shoppinglist/{id} returns created items").hasSize(3);

        assertThat(items.get(0).getName()).as("Item 1 has expected name.").isEqualTo(newItem1.getName());
        assertThat(items.get(0).getCategory()).as("Item 1 has expected category.").isEqualTo(newItem1.getCategory());
        assertThat(items.get(0).isChecked()).as("Item 1 is not checked").isFalse();

        assertThat(items.get(1).getName()).as("Item 2 has expected name.").isEqualTo(newItem2.getName());
        assertThat(items.get(1).getCategory()).as("Item 2 has expected category.").isEqualTo(newItem2.getCategory());
        assertThat(items.get(1).isChecked()).as("Item 2 is not checked").isFalse();

        assertThat(items.get(2).getName()).as("Item 3 has expected name.").isEqualTo(newItem3.getName());
        assertThat(items.get(2).getCategory()).as("Item 3 has expected category.").isEqualTo(newItem3.getCategory());
        assertThat(items.get(2).isChecked()).as("Item 3 is not checked").isFalse();
    }

    @Test
    @Sql("/InsertTestList.sql")
    @Sql("/InsertTestItem.sql")
    public void updateNameOfExistingListItem() {
        ShoppingListInfoDto list = webClient.get()
                .uri("/api/shoppinglists")
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class)
                .hasSize(1)
                .returnResult()
                .getResponseBody()
                .get(0);
        ShoppingListItemDto item = webClient.get()
                .uri("/api/shoppinglist/{id}", list.getId())
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListItemDto.class)
                .hasSize(1)
                .returnResult()
                .getResponseBody()
                .get(0);

        var updateItemDto = new ShoppingListItemUpdateDto();
        updateItemDto.setName("Updated Name");
        webClient.put()
                .uri("/api/shoppinglist/{id}/item/{itemId}", list.getId(), item.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(updateItemDto)
                .exchange().expectStatus()
                .is2xxSuccessful();

        ShoppingListItemDto updatedItem = webClient.get()
                .uri("/api/shoppinglist/{id}", list.getId())
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListItemDto.class)
                .hasSize(1)
                .returnResult()
                .getResponseBody()
                .get(0);
        assertThat(updatedItem.getName()).as("Item has updated name.").isEqualTo(updatedItem.getName());
        assertThat(updatedItem.getCategory()).as("Item still has no category.").isNull();
        assertThat(updatedItem.isChecked()).as("Item is still unchecked.").isFalse();
    }

    @Test
    @Sql("/InsertTestList.sql")
    @Sql("/InsertTestItem.sql")
    public void updateCategoryOfExistingListItemWithoutCategory() {
        ShoppingListInfoDto list = webClient.get()
                .uri("/api/shoppinglists")
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class)
                .hasSize(1)
                .returnResult()
                .getResponseBody()
                .get(0);
        ShoppingListItemDto item = webClient.get()
                .uri("/api/shoppinglist/{id}", list.getId())
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListItemDto.class)
                .hasSize(1)
                .returnResult()
                .getResponseBody()
                .get(0);
        assertThat(item.getCategory()).as("Item has no category before update.").isNull();

        var updateItemDto = new ShoppingListItemUpdateDto();
        updateItemDto.setName(item.getName());
        updateItemDto.setCategory("Test Category");
        webClient.put()
                .uri("/api/shoppinglist/{id}/item/{itemId}", list.getId(), item.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(updateItemDto)
                .exchange().expectStatus()
                .is2xxSuccessful();

        ShoppingListItemDto updatedItem = webClient.get()
                .uri("/api/shoppinglist/{id}", list.getId())
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListItemDto.class)
                .hasSize(1)
                .returnResult()
                .getResponseBody()
                .get(0);
        assertThat(updatedItem.getName()).as("Item still has old name.").isEqualTo(item.getName());
        assertThat(updatedItem.getCategory()).as("Item now has a category.").isEqualTo(updatedItem.getCategory());
        assertThat(updatedItem.isChecked()).as("Item is still unchecked.").isFalse();
    }

}
