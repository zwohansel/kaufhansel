package de.hanselmann.shoppinglist.controller;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDateTime;
import java.util.Properties;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.info.BuildProperties;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase.Replace;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.TestPropertySource;

import de.hanselmann.shoppinglist.model.InfoMessage;
import de.hanselmann.shoppinglist.model.InfoMessage.Severity;
import de.hanselmann.shoppinglist.repository.InfoMessageRepository;
import de.hanselmann.shoppinglist.restapi.dto.InfoDto;
import de.hanselmann.shoppinglist.restapi.dto.InfoDto.SeverityDto;
import de.hanselmann.shoppinglist.restapi.dto.transformer.DtoTransformer;

@TestPropertySource(locations = "classpath:application-test.properties")
@DataJpaTest
@AutoConfigureTestDatabase(replace = Replace.NONE)
public class InfoControllerTest {

    @Autowired
    private InfoMessageRepository infoMessageRepository;

    @Test
    public void returnsValidInfoMessage() {
        Properties properties = new Properties();
        properties.setProperty("version", "test-1234");
        BuildProperties buildProperties = new BuildProperties(properties);
        InfoController cut = new InfoController(new DtoTransformer(), buildProperties, infoMessageRepository);

        InfoMessage infoMessage = new InfoMessage();
        infoMessage.setEnabled(true);
        infoMessage.setMessage("test");
        infoMessage.setSeverity(Severity.INFO);
        infoMessage.setValidFrom(LocalDateTime.now().minusHours(1));
        infoMessage.setValidTo(LocalDateTime.now().plusHours(1));
        infoMessageRepository.save(infoMessage);

        ResponseEntity<InfoDto> response = cut.getInfo();
        assertThat(response).isNotNull();
        InfoDto info = response.getBody();
        assertThat(info).isNotNull();
        assertThat(info.getMessage().get().getMessage()).isEqualTo("test");
        assertThat(info.getMessage().get().getSeverity()).isEqualTo(SeverityDto.INFO);
        assertThat(info.getApiVersion()).isEqualTo("test-1234");
    }

    @Test
    public void doesNotReturnInfoMessageIfExpired() {
        Properties properties = new Properties();
        BuildProperties buildProperties = new BuildProperties(properties);
        InfoController cut = new InfoController(new DtoTransformer(), buildProperties, infoMessageRepository);

        InfoMessage infoMessage = new InfoMessage();
        infoMessage.setEnabled(true);
        infoMessage.setMessage("test");
        infoMessage.setSeverity(Severity.INFO);
        infoMessage.setValidFrom(LocalDateTime.now().minusHours(2));
        infoMessage.setValidTo(LocalDateTime.now().minusHours(1));
        infoMessageRepository.save(infoMessage);

        ResponseEntity<InfoDto> response = cut.getInfo();
        assertThat(response).isNotNull();
        InfoDto info = response.getBody();
        assertThat(info).isNotNull();
        assertThat(info.getMessage()).isEmpty();
    }

}
