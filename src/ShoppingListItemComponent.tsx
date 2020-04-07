import { List, Checkbox } from "antd";
import React from "react";
import { ShoppingListItem } from "./ShoppingListItem";

export interface ShoppingListItemComponentProps {
  item: ShoppingListItem;
  onItemCheckedChange: (checked: boolean) => void;
}

export function ShoppingListItemComponent(
  props: ShoppingListItemComponentProps
) {
  return (
    <List.Item
      key={props.item.name}
      style={{
        textDecoration: props.item.checked ? "line-through" : "none",
      }}
    >
      <Checkbox
        style={{ marginRight: "1em" }}
        value={props.item.checked}
        onChange={(event) =>
          props.onItemCheckedChange(event.target.checked)
        }
      />
      {props.item.name}
    </List.Item>
  );
}
