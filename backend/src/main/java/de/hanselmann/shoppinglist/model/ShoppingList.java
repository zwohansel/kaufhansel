package de.hanselmann.shoppinglist.model;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;

public class ShoppingList {

    @Id
    private ObjectId id;
    private List<ShoppingListItem> items = new ArrayList<>();

    public ObjectId getId() {
        return id;
    }

    public List<ShoppingListItem> getItems() {
        return new ArrayList<>(items);
    }

    public void addItem(ShoppingListItem item) {
        items.add(item);
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
}
