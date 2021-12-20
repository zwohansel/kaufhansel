package de.hanselmann.shoppinglist.model;

import javax.persistence.*;
import java.util.List;

@Entity
@Table(name = "CATEGORIES")
public class ShoppingListCategory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "NAME", nullable = false)
    private String name;

    @ManyToOne
    @JoinColumn(name = "LIST_ID", nullable = false)
    private ShoppingList list;

    @OneToMany(mappedBy = "category")
    private List<ShoppingListItem> items;

    protected ShoppingListCategory() {

    }

    public ShoppingListCategory(String name, ShoppingList list) {
        this.name = name;
        this.list = list;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public ShoppingList getList() {
        return list;
    }
}
