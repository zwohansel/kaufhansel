package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;

@Entity
@Table(name = "LISTS")
public class ShoppingList {

    @Id
    private long id;

    @Column(name = "NAME", nullable = false)
    private String name;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "CREATED_BY", nullable = false)
    private ShoppingListUser createdBy;

    @OneToMany(mappedBy = "list")
    private List<ShoppingListItem> items = new ArrayList<>();

    @OneToMany(mappedBy = "list")
    private List<ShoppingListCategory> categories = new ArrayList<>();

    @OneToMany(mappedBy = "list")
    private List<ShoppingListPermissions> permissions = new ArrayList<>();

    public ShoppingList() {
    }

    protected ShoppingList(long id, String name, LocalDateTime createdAt, ShoppingListUser createdBy,
            List<ShoppingListItem> items) {
        this.id = id;
        this.name = name;
        this.createdAt = createdAt;
        this.createdBy = createdBy;
        this.items = items;
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

    public List<ShoppingListItem> getItems() {
        return Collections.unmodifiableList(items);
    }

    public List<ShoppingListPermissions> getUsers() {
        return Collections.unmodifiableList(permissions);
    }

    public List<ShoppingListCategory> getCategories() {
        return Collections.unmodifiableList(categories);
    }

    // TODO: Not the owning side!
    public void addItem(ShoppingListItem item) {
        items.add(item);
    }

    // TODO: Not the owning side!
    public void addUser(ShoppingListPermissions permission) {
        permissions.add(permission);
    }

    public List<ShoppingListItem> getByChecked(boolean checked) {
        return items.stream().filter(item -> item.isChecked() == checked).collect(Collectors.toList());
    }

    public Optional<ShoppingListItem> findItemById(long id) {
        return items.stream().filter(item -> item.getId() == id).findAny();
    }

    // TODO: Not the owning side!
    public Optional<ShoppingListItem> deleteItemById(long id) {
        Optional<ShoppingListItem> item = findItemById(id);
        item.ifPresent(items::remove);
        return item;
    }

    // TODO: Not the owning side!
    public void deleteItemIf(Predicate<ShoppingListItem> filter) {
        items.removeIf(filter);
    }

    /**
     * Removes all items from the list
     *
     * @return the list of removed items
     */
    // TODO: Not the owning side!
    public List<ShoppingListItem> clearItems() {
        List<ShoppingListItem> copy = new ArrayList<>(items);
        items.clear();
        return copy;
    }

    // TODO: Not the owning side!
    public void removeUserFromShoppingList(ShoppingListPermissions permission) {
        permissions.remove(permission);
    }

    // TODO: Not the owning side!
    public boolean moveItem(ShoppingListItem item, int targetIndex) {
        if (targetIndex < 0) {
            throw new IndexOutOfBoundsException();
        }

        int currentIndex = items.indexOf(item);

        if (currentIndex < 0) {
            return false;
        }
        items.remove(currentIndex);
        items.add(Math.min(items.size(), targetIndex), item);
        return true;
    }
}
