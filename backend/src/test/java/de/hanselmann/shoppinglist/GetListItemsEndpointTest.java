package de.hanselmann.shoppinglist;

import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.service.AuthenticatedUserService;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@WebServerTestWithTestUser
public class GetListItemsEndpointTest {
    private static final String PATH = "/api/shoppinglist/{id}";

    @Autowired
    private WebTestClient webClient;

    @Autowired
    private ShoppingListUserRepository userRepository;

    @MockBean
    private AuthenticatedUserService authenticatedUserService;

    public static List<ShoppingListItemDto> getListItems(WebTestClient webClient, ShoppingListInfoDto list) {
        return requestListItems(webClient, list).returnResult().getResponseBody();
    }

    private static WebTestClient.ListBodySpec<ShoppingListItemDto> requestListItems(WebTestClient webClient,
                                                                                    ShoppingListInfoDto list) {
        return webClient.get()
                .uri(PATH, list.getId())
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListItemDto.class);
    }

    public static ShoppingListItemDto getSingleListItem(WebTestClient webClient, ShoppingListInfoDto list) {
        return requestListItems(webClient, list).hasSize(1).returnResult().getResponseBody().get(0);
    }

    @BeforeEach
    public void loginTestUser() {
        when(authenticatedUserService.findCurrentUser())
                .then(mock -> userRepository.findUserByEmailAddress("test@test.test"));
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void getShoppingListItemsReturnsEmptyListIfNoItemsArePresent() {
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(webClient);
        webClient.get()
                .uri(PATH, list.getId())
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListItemDto.class)
                .hasSize(0);
    }

    @Test
    @Sql("/InsertTestList.sql")
    @Sql("/InsertTestItem.sql")
    public void getExistingShoppingListItem() {
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(webClient);
        List<ShoppingListItemDto> items = getListItems(webClient, list);
        assertThat(items).as(PATH + " returns existing item").singleElement();
        assertThat(items.get(0).getName()).as("Item has expected name.").isEqualTo("Test Item");
        assertThat(items.get(0).getCategory()).as("Item has no category.").isNull();
        assertThat(items.get(0).isChecked()).as("Item is not checked").isFalse();
    }
}
