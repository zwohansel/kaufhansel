package de.hanselmann.shoppinglist.model;

import org.springframework.data.annotation.Id;

import io.leangen.graphql.annotations.GraphQLId;
import io.leangen.graphql.annotations.GraphQLNonNull;
import io.leangen.graphql.annotations.GraphQLQuery;

public class ShoppingListItem {

    @Id
    private String id;
    private String name;
    private Boolean checked;
    private String assignee;

    public ShoppingListItem() {
        this(null);
    }

    public ShoppingListItem(String name) {
        this.id = null;
        this.name = name;
        this.checked = false;
        this.assignee = "";
    }

    @GraphQLQuery(name = "_id")
    @GraphQLId
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    @GraphQLQuery(name = "name")
    public @GraphQLNonNull String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @GraphQLQuery(name = "checked")
    public Boolean isChecked() {
        return checked;
    }

    public void setChecked(Boolean checked) {
        this.checked = checked;
    }

    @GraphQLQuery(name = "assignee")
    public String getAssignee() {
        return assignee;
    }

    public void setAssignee(String assignee) {
        this.assignee = assignee;
    }

}
