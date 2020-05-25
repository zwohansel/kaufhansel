import { ShoppingOutlined } from "@ant-design/icons";
import { Empty, List } from "antd";
import React from "react";
import { ShoppingListItem } from "./ShoppingListItem";
import { ShoppingListItemComponent } from "./ShoppingListItemComponent";

export enum ShoppingListFilter {
  all,
  checked,
  unchecked
}

export interface ShoppingListComponentProps {
  className?: string;
  assigneeCandidates?: string[];
  shoppingList: ShoppingListItem[];
  filter: ShoppingListFilter;
  onItemCheckedChange: (item: ShoppingListItem, checked: boolean) => void;
  onItemDeleted: (item: ShoppingListItem) => Promise<void>;
  onItemAssigneeChange?: (item: ShoppingListItem, assignee: string) => void;
}

function ShoppingListComponent(props: ShoppingListComponentProps) {
  const filteredList = props.shoppingList.filter(item => {
    switch (props.filter) {
      case ShoppingListFilter.all:
        return true;
      case ShoppingListFilter.checked:
        return item.checked;
      case ShoppingListFilter.unchecked:
        return !item.checked;
    }
  });

  if (filteredList.length === 0) {
    return (
      <Empty
        description="Kaufstu was!?"
        image={<ShoppingOutlined style={{ fontSize: "6em" }} />}
        className={props.className}
      />
    );
  }

  return (
    <List
      className={props.className}
      dataSource={filteredList}
      size="small"
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
