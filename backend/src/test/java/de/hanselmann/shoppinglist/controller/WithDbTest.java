package de.hanselmann.shoppinglist.controller;

import javax.annotation.Resource;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.support.AnnotationConfigContextLoader;
import org.springframework.transaction.annotation.Transactional;

import de.hanselmann.shoppinglist.repository.InviteRepository;

@SpringBootTest()
@TestPropertySource(locations = "classpath:application-test.properties")
//@ContextConfiguration(classes = { StudentJpaConfig.class }, loader = AnnotationConfigContextLoader.class)
@ContextConfiguration(loader = AnnotationConfigContextLoader.class)
@Transactional

public class WithDbTest {

    @Resource
    InviteRepository inviteRepository;

    @Test
    public void test() {

    }
}
