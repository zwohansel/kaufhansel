package de.hanselmann.shoppinglist.testutils;

import org.junit.jupiter.api.extension.AfterTestExecutionCallback;
import org.junit.jupiter.api.extension.BeforeAllCallback;
import org.junit.jupiter.api.extension.ExtensionContext;
import org.springframework.context.ApplicationContext;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import de.hanselmann.shoppinglist.repository.InfoMessageRepository;
import de.hanselmann.shoppinglist.repository.ListInviteRepository;
import de.hanselmann.shoppinglist.repository.PendingRegistrationsRepository;
import de.hanselmann.shoppinglist.repository.ShoppingListCategoriesRepository;
import de.hanselmann.shoppinglist.repository.ShoppingListItemsRepository;
import de.hanselmann.shoppinglist.repository.ShoppingListPermissionsRepository;
import de.hanselmann.shoppinglist.repository.ShoppingListRepository;
import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.repository.TokenRepository;

/**
 * Provides a clean database for each test.
 */
public class CleanDatabaseExtension implements BeforeAllCallback, AfterTestExecutionCallback {

    @Override
    public void beforeAll(ExtensionContext context) throws Exception {
        cleanDataBase(context);
    }

    @Override
    public void afterTestExecution(ExtensionContext context) throws Exception {
        cleanDataBase(context);
    }

    private void cleanDataBase(ExtensionContext context) {
        ApplicationContext appContext = SpringExtension.getApplicationContext(context);
        appContext.getBean(TokenRepository.class).deleteAll();
        appContext.getBean(InfoMessageRepository.class).deleteAll();
        appContext.getBean(ListInviteRepository.class).deleteAll();
        appContext.getBean(PendingRegistrationsRepository.class).deleteAll();
        appContext.getBean(ShoppingListItemsRepository.class).deleteAll();
        appContext.getBean(ShoppingListCategoriesRepository.class).deleteAll();
        appContext.getBean(ShoppingListPermissionsRepository.class).deleteAll();
        appContext.getBean(ShoppingListRepository.class).deleteAll();
        appContext.getBean(ShoppingListUserRepository.class).deleteAll();
    }

}
