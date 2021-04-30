package de.hanselmann.shoppinglist.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import javax.persistence.Entity;

import org.springframework.data.annotation.Id;

@Entity
public class ShoppingList {

    @Id
    private long id;
    private String name;
    private List<ShoppingListItem> items = new ArrayList<>();
    private List<ShoppingListUserReference> users = new ArrayList<>();

    public ShoppingList() {
    }

    protected ShoppingList(long id, String name, List<ShoppingListItem> items,
            List<ShoppingListUserReference> users) {
        this.id = id;
        this.name = name;
        this.items = items;
        this.users = users;
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

    public List<ShoppingListUserReference> getUsers() {
        return Collections.unmodifiableList(users);
    }

    public void addItem(ShoppingListItem item) {
        items.add(item);
    }

    public void addUser(ShoppingListUserReference user) {
        users.add(user);
    }

    public List<ShoppingListItem> getByChecked(boolean checked) {
        return items.stream().filter(item -> item.isChecked() == checked).collect(Collectors.toList());
    }

    public Optional<ShoppingListItem> findItemById(long id) {
        return items.stream().filter(item -> item.getId() == id).findAny();
    }

    public Optional<ShoppingListItem> deleteItemById(long id) {
        Optional<ShoppingListItem> item = findItemById(id);
        item.ifPresent(items::remove);
        return item;
    }

    public void deleteItemIf(Predicate<ShoppingListItem> filter) {
        items.removeIf(filter);
    }

    /**
     * Removes all items from the list
     *
     * @return the list of removed items
     */
    public List<ShoppingListItem> clearItems() {
        List<ShoppingListItem> copy = new ArrayList<>(items);
        items.clear();
        return copy;
    }

    public void removeUserFromShoppingList(long userId) {
        users.removeIf(user -> user.getUserId() == userId);
    }

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
