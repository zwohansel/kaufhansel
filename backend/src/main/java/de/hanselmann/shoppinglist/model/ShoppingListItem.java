package de.hanselmann.shoppinglist.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
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

    @ManyToOne
    @JoinColumn(name = "CATEGORY_ID")
    private ShoppingListCategory category;

    @ManyToOne
    @JoinColumn(name = "LIST_ID", nullable = false)
    private ShoppingList list;

    public ShoppingListItem(ShoppingList list) {
        this(null, list);
    }

    public ShoppingListItem(String name, ShoppingList list) {
        this.name = name;
        this.checked = false;
        this.list = list;
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
        if (category.getList().getId() != list.getId()) {
            throw new IllegalArgumentException("Category " + category.getName() + " is from another list.");
        }
        this.category = category;
    }

}
