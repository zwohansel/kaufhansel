package de.hanselmann.shoppinglist.restapi.dto;

import java.util.Optional;

public class DeleteItemDto {
    private Optional<String> ofCategory;

    public Optional<String> getOfCategory() {
        return ofCategory;
    }

    public void setOfCategory(String ofCategory) {
        this.ofCategory = Optional.ofNullable(ofCategory);
    }

    public void setOfCategory(Optional<String> ofCategory) {
        this.ofCategory = ofCategory;
    }

}
