import React from "react";
import { List } from "antd";
import { ShoppingListItemComponent } from "./ShoppingListItemComponent";
import { ShoppingListItem } from "../shared/ShoppingListItem";

export interface ShoppingListListComponentProps {
  assigneeCandidates: string[];
  shoppingList: ShoppingListItem[];
  onItemCheckedChange: (item: ShoppingListItem, checked: boolean) => void;
  onItemDeleted: (item: ShoppingListItem) => void;
  onItemAssigneeChange: (item: ShoppingListItem, assignee: string) => void;
}

function ShoppingListListComponent(props: ShoppingListListComponentProps) {
  return (
    <List
      dataSource={props.shoppingList}
      renderItem={item => {
        return (
          <ShoppingListItemComponent
            item={item}
            assigneeCandidates={props.assigneeCandidates}
            onItemCheckedChange={checked => props.onItemCheckedChange(item, checked)}
            onItemDeleted={() => props.onItemDeleted(item)}
            onItemAssigneeChange={assignee => props.onItemAssigneeChange(item, assignee)}
          />
        );
      }}
    />
  );
}

export default ShoppingListListComponent;
