package de.hanselmann.shoppinglist.model;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;

public class ShoppingListItem {

    @Id
    private ObjectId id;
    private String name;
    private Boolean checked;
    private String assignee;

    public ShoppingListItem() {
        this(null);
    }

    public ShoppingListItem(String name) {
        this.id = new ObjectId();
        this.name = name;
        this.checked = false;
        this.assignee = "";
    }

    public ObjectId getId() {
        return id;
    }

    public void setId(ObjectId id) {
        this.id = id;
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

    public String getAssignee() {
        return assignee;
    }

    public void setAssignee(String assignee) {
        this.assignee = assignee;
    }

}
