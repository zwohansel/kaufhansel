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
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
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
    public void postToShoppingListEndpointCreatesNewList() {
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

}
