package de.hanselmann.shoppinglist.controller;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest
@TestPropertySource(locations = "classpath:application-test.properties")
@AutoConfigureMockMvc
public class ShoppingListControllerIntegrationTest {
    @Autowired
    private ShoppingListController cut;

    @Test
    public void test() {
        assertThat(cut).isNotNull();
    }
}
