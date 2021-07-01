package de.hanselmann.shoppinglist.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

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
import org.springframework.transaction.annotation.Transactional;

import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.service.AuthenticatedUserService;

@SpringBootTest(webEnvironment = WebEnvironment.NONE)
@TestPropertySource(locations = "classpath:application-test.properties")
@Transactional
@AutoConfigureTestDatabase(replace = Replace.NONE)
@ActiveProfiles("test")
public class ShoppingListControllerTest {

    @Autowired
    private ShoppingListController cut;

    @Autowired
    private ShoppingListUserRepository userRepository;

    @MockBean
    private AuthenticatedUserService authenticatedUserService;

    @Test
    public void throwExceptionIfUserIsNotAuthenticated() {
        when(authenticatedUserService.findCurrentUser()).thenReturn(Optional.empty());
        assertThrows(IllegalArgumentException.class, () -> cut.getShoppingLists());
    }

    @Test
    public void getShoppingListsReturnsEmptyListIfUserHasNoLists() {
        createTestUser();

        ResponseEntity<List<ShoppingListInfoDto>> lists = cut.getShoppingLists();
        assertThat(lists).isNotNull().extracting(ResponseEntity::getStatusCode).isEqualTo(HttpStatus.OK);
        assertThat(lists.getBody()).isEmpty();
    }

    @Test
    public void getShoppingListsReturnsCreatedList() {
        createTestUser();

        var newList = new NewShoppingListDto();
        newList.setName("TestList");
        cut.createShoppingList(newList);

        ResponseEntity<List<ShoppingListInfoDto>> lists = cut.getShoppingLists();
        assertThat(lists).isNotNull().extracting(ResponseEntity::getStatusCode).isEqualTo(HttpStatus.OK);
        assertThat(lists.getBody()).hasSize(1);
        ShoppingListInfoDto listInfo = lists.getBody().get(0);
        assertThat(listInfo.getName()).isEqualTo(newList.getName());
    }

    private long createTestUser() {
        var user = new ShoppingListUser(false, "test@test.test", "test", "test", LocalDateTime.now());
        userRepository.save(user);
        when(authenticatedUserService.findCurrentUser()).thenReturn(Optional.of(user));
        return user.getId();
    }

}
