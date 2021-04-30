package de.hanselmann.shoppinglist.model;

import javax.persistence.Entity;

import org.springframework.data.annotation.Id;

@Entity
public class ShoppingListItem {

    @Id
    private long id;
    private String name;
    private Boolean checked;
    private String assignee;

    public ShoppingListItem() {
        this(null);
    }

    public ShoppingListItem(String name) {
        this.name = name;
        this.checked = false;
        this.assignee = "";
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

    public String getAssignee() {
        return assignee;
    }

    public void setAssignee(String assignee) {
        this.assignee = assignee;
    }

}
