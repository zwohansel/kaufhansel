package de.hanselmann.shoppinglist.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase.Replace;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.test.context.jdbc.SqlMergeMode.MergeMode;
import org.springframework.transaction.annotation.Transactional;

import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListPermissionsDto;
import de.hanselmann.shoppinglist.service.AuthenticatedUserService;

@SpringBootTest(webEnvironment = WebEnvironment.NONE)
@TestPropertySource(locations = "classpath:application-test.properties")
@Transactional
@AutoConfigureTestDatabase(replace = Replace.NONE)
@ActiveProfiles("test")
@Sql("/InsertTestUser.sql")
@SqlMergeMode(MergeMode.MERGE) // Execute method level @Sql after call level @Sql
public class ShoppingListControllerTest {

    @Autowired
    private ShoppingListController listController;

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
    public void throwExceptionIfUserIsNotAuthenticated() {
        when(authenticatedUserService.findCurrentUser()).thenReturn(Optional.empty());
        assertThrows(IllegalArgumentException.class, () -> listController.getShoppingLists());
    }

    @Test
    public void getShoppingListsReturnsEmptyListIfUserHasNoLists() {
        ResponseEntity<List<ShoppingListInfoDto>> lists = listController.getShoppingLists();
        assertThat(lists).isNotNull();
        assertThat(lists.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(lists.getBody()).as("Response body contains an empty list").isEmpty();
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void getShoppingListsReturnsExistingList() {
        ResponseEntity<List<ShoppingListInfoDto>> lists = listController.getShoppingLists();
        assertThat(lists).isNotNull();
        assertThat(lists.getStatusCode()).isEqualTo(HttpStatus.OK);

        assertThat(lists.getBody()).as("Response body contains single list info object").singleElement();
        ShoppingListInfoDto listInfo = lists.getBody().get(0);
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
    public void createShoppingListCreatesNewList() {
        final String newListName = "New Shopping List";
        var newListDto = new NewShoppingListDto();
        newListDto.setName(newListName);
        var createResponse = listController.createShoppingList(newListDto);
        assertThat(createResponse).isNotNull();
        assertThat(createResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(createResponse.getBody()).as("Response contains new list.").isNotNull();
        assertThat(createResponse.getBody().getName()).isEqualTo(newListName);

        ResponseEntity<List<ShoppingListInfoDto>> lists = listController.getShoppingLists();
        assertThat(lists.getBody()).as("getShoppingLists returns new list")
                .isNotNull()
                .singleElement()
                .extracting(ShoppingListInfoDto::getName).isEqualTo(newListName);
    }

    @Test
    public void createShoppingListReturnsBadRequestIfNameIsNull() {
        var createResponse = listController.createShoppingList(new NewShoppingListDto());
        assertThat(createResponse).isNotNull();
        assertThat(createResponse.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);

        // getShoppingLists should still return an empty list
        ResponseEntity<List<ShoppingListInfoDto>> lists = listController.getShoppingLists();
        assertThat(lists).isNotNull().extracting(ResponseEntity::getStatusCode).isEqualTo(HttpStatus.OK);
        assertThat(lists.getBody()).isEmpty();
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void deleteShoppingListDeletesExistingList() {
        ResponseEntity<List<ShoppingListInfoDto>> listsBeforeDelete = listController.getShoppingLists();
        assertThat(listsBeforeDelete.getBody()).singleElement();

        long listId = listsBeforeDelete.getBody().get(0).getId();
        var deleteResponse = listController.deleteShoppingList(listId);
        assertThat(deleteResponse).isNotNull();
        assertThat(deleteResponse.getStatusCode()).isEqualTo(HttpStatus.NO_CONTENT);

        ResponseEntity<List<ShoppingListInfoDto>> listsAfterDelete = listController.getShoppingLists();
        assertThat(listsAfterDelete).isNotNull().extracting(ResponseEntity::getStatusCode).isEqualTo(HttpStatus.OK);
        assertThat(listsAfterDelete.getBody()).isEmpty();
    }

}
