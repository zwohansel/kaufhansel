package de.hanselmann.shoppinglist.testutils;

import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ExtendWith({CleanDatabaseExtension.class})
@TestPropertySource(locations = "classpath:application-test.properties")
@ActiveProfiles("test")
@Sql("/InsertTestUser.sql")
@SqlMergeMode(SqlMergeMode.MergeMode.MERGE) // Execute method level @Sql after call level @Sql
public @interface WebServerTestWithTestUser {
}
