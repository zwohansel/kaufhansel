package de.hanselmann.shoppinglist.controller;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.info.BuildProperties;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

import de.hanselmann.shoppinglist.model.InfoMessage;
import de.hanselmann.shoppinglist.repository.InfoMessageRepository;
import de.hanselmann.shoppinglist.restapi.InfoApi;
import de.hanselmann.shoppinglist.restapi.dto.InfoDto;
import de.hanselmann.shoppinglist.restapi.dto.InfoDto.InfoMessageDto;
import de.hanselmann.shoppinglist.restapi.dto.transformer.DtoTransformer;

@RestController
public class InfoController implements InfoApi {

    private final DtoTransformer dtoTransformer;
    private final BuildProperties buildProperties;
    private final InfoMessageRepository messageRepository;

    @Autowired
    public InfoController(DtoTransformer dtoTransformer, BuildProperties buildProperties,
            InfoMessageRepository messageRepository) {
        this.dtoTransformer = dtoTransformer;
        this.buildProperties = buildProperties;
        this.messageRepository = messageRepository;
    }

    @Override
    public ResponseEntity<InfoDto> getInfo() {
        Optional<InfoMessageDto> message = messageRepository
                .findValidMessages()
                .filter(InfoMessage::isEnabled)
                .findFirst()
                .map(dtoTransformer::map);
        String version = buildProperties.getVersion();
        return ResponseEntity.ok(InfoDto.create(version, message));
    }

}
