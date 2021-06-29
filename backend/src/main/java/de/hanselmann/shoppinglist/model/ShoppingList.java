package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.Table;

@Entity
@Table(name = "LISTS")
public class ShoppingList {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "NAME", nullable = false)
    private String name;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @ManyToOne
    @JoinColumn(name = "CREATED_BY", nullable = false)
    private ShoppingListUser createdBy;

    @OneToMany(mappedBy = "list", cascade = CascadeType.REMOVE)
    private List<ShoppingListItem> items = new ArrayList<>();

    @OneToMany(mappedBy = "list", cascade = CascadeType.REMOVE)
    private List<ShoppingListCategory> categories = new ArrayList<>();

    @OneToMany(mappedBy = "list", cascade = CascadeType.REMOVE)
    private List<ShoppingListPermission> permissions = new ArrayList<>();

    protected ShoppingList() {
    }

    public ShoppingList(String name, ShoppingListUser createdBy, LocalDateTime createdAt) {
        this.name = name;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
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

    public List<ShoppingListItem> getItems() {
        return Collections.unmodifiableList(items);
    }

    public List<ShoppingListPermission> getPermissions() {
        return Collections.unmodifiableList(permissions);
    }

    public Optional<ShoppingListPermission> getPermissionOfUser(ShoppingListUser user) {
        return permissions.stream().filter(permission -> permission.getUser().getId() == user.getId()).findAny();
    }

    public List<ShoppingListCategory> getCategories() {
        return Collections.unmodifiableList(categories);
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
    public void removeUserFromShoppingList(ShoppingListPermission permission) {
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
