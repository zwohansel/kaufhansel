package de.hanselmann.shoppinglist.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "ITEMS")
public class ShoppingListItem {

    @Id
    private long id;

    @Column(name = "NAME", nullable = false)
    private String name;

    @Column(name = "CHECKED", nullable = false)
    private Boolean checked;

    @Column(name = "CATEGORY_ID")
    private ShoppingListCategory category;

    public ShoppingListItem() {
        this(null);
    }

    public ShoppingListItem(String name) {
        this.name = name;
        this.checked = false;
        this.category = null;
    }

    public long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Boolean isChecked() {
        return checked;
    }

    public void setChecked(Boolean checked) {
        this.checked = checked;
    }

    public ShoppingListCategory getCategory() {
        return category;
    }

    public void setCategory(ShoppingListCategory category) {
        this.category = category;
    }

}
