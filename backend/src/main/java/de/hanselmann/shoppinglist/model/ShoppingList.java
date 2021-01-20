package de.hanselmann.shoppinglist.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;

public class ShoppingList {

    @Id
    private ObjectId id;
    private String name;
    private List<ShoppingListItem> items = new ArrayList<>();
    private List<ShoppingListUserReference> users = new ArrayList<>();

    public ObjectId getId() {
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

    public Optional<ShoppingListItem> findItemById(String id) {
        return items.stream().filter(item -> item.getId().equals(id)).findAny();
    }

    public Optional<ShoppingListItem> deleteItemById(String id) {
        Optional<ShoppingListItem> item = findItemById(id);
        item.ifPresent(items::remove);
        return item;
    }

    public void clearItems() {
        items.clear();
    }

    public boolean deleteUser(ObjectId userId) {
        return users.removeIf(user -> user.getUserId().equals(userId));
    }
}
