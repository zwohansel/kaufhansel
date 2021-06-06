package de.hanselmann.shoppinglist.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "CATEGORIES")
public class ShoppingListCategory {

    @Id
    private long id;

    @Column(name = "NAME", nullable = false)
    private String name;

    public ShoppingListCategory(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

}
