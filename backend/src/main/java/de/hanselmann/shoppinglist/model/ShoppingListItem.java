package de.hanselmann.shoppinglist.model;

import java.util.Objects;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import org.springframework.lang.Nullable;

@Entity
@Table(name = "ITEMS")
public class ShoppingListItem {

    @ManyToOne
    @JoinColumn(name = "LIST_ID", nullable = false)
    private final ShoppingList list;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name = "NAME", nullable = false)
    private String name;
    @Column(name = "CHECKED", nullable = false)
    private Boolean checked;
    @ManyToOne
    @JoinColumn(name = "CATEGORY_ID")
    private ShoppingListCategory category;
    @Column(name = "POSITION", nullable = false)
    private int position;

    protected ShoppingListItem() {
        this(null);
    }

    public ShoppingListItem(ShoppingList list) {
        this(null, list);
    }

    public ShoppingListItem(String name, ShoppingList list) {
        this.name = name;
        this.checked = false;
        this.list = list;
        this.category = null;
    }

    public Long getId() {
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

    public void setCategory(@Nullable ShoppingListCategory category) {
        if (category != null && !Objects.equals(category.getList().getId(), list.getId())) {
            throw new IllegalArgumentException("Category " + category.getName() + " is from another list.");
        }
        this.category = category;
    }

    public void removeFromCategory() {
        this.category = null;
    }

    public @Nullable String getCategoryName() {
        return category == null ? null : category.getName();
    }

    public ShoppingList getList() {
        return list;
    }

    public int getPosition() {
        return position;
    }

    public void setPosition(int order) {
        this.position = order;
    }

}
