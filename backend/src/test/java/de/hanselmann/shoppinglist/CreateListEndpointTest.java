package de.hanselmann.shoppinglist;

import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListPermissionsDto;
import de.hanselmann.shoppinglist.service.AuthenticatedUserService;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.reactive.server.WebTestClient;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@WebServerTestWithTestUser
public class CreateListEndpointTest {
    private static final String PATH = "/api/shoppinglist";

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
    public void createsNewList() {
        final String newListName = "New Shopping List";
        var newListDto = new NewShoppingListDto();
        newListDto.setName(newListName);

        ShoppingListInfoDto createdList = webClient.post()
                .uri(PATH)
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

        List<ShoppingListInfoDto> lists = GetListsEndpointTest.getLists(webClient);

        assertThat(lists).as("/shoppinglist returns created list").singleElement();
        assertThat(lists.get(0).getId()).as("id of list returned by /shoppinglist matches id of created list")
                .isEqualTo(createdList.getId());
    }

    @Test
    public void returnsBadRequestIfNoNameIsGiven() {
        webClient.post()
                .uri(PATH)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(new NewShoppingListDto())
                .exchange()
                .expectStatus()
                .isBadRequest();

        // Check that no list has been created
        assertThat(GetListsEndpointTest.getLists(webClient)).isEmpty();
    }
}
