import { List } from "antd";
import React from "react";
import { ShoppingListItem } from "./ShoppingListItem";
import { ShoppingListItemComponent } from "./ShoppingListItemComponent";

export interface ShoppingListComponentProps {
  assigneeCandidates?: string[];
  shoppingList: ShoppingListItem[];
  onItemCheckedChange: (item: ShoppingListItem, checked: boolean) => void;
  onItemDeleted: (item: ShoppingListItem) => void;
  onItemAssigneeChange?: (item: ShoppingListItem, assignee: string) => void;
}

function ShoppingListComponent(props: ShoppingListComponentProps) {
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
            onItemAssigneeChange={assignee => {
              if (props.onItemAssigneeChange) {
                props.onItemAssigneeChange(item, assignee);
              }
            }}
          />
        );
      }}
    />
  );
}

export default ShoppingListComponent;
