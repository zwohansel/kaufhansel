package de.hanselmann.shoppinglist.service;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.mongodb.MongoTransactionManager;
import org.springframework.test.context.TestPropertySource;

import de.hanselmann.shoppinglist.repository.ShoppingListRepository;

@SpringBootTest(classes = { ShoppingListService.class })
@TestPropertySource(locations = "classpath:application-test.properties")
public class ShoppingListServiceIntegrationTest {

    @MockBean
    private ShoppingListRepository shoppingListRepository;

    @MockBean
    private ShoppingListUserService userService;

    @MockBean
    private MongoTransactionManager transactionManager;

    @Autowired
    private ShoppingListService cut;

    @Test
    public void test() {
        assertThat(cut).isNotNull();
    }
}
