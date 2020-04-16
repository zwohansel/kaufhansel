import { DeleteFilled } from "@ant-design/icons";
import { Button, Checkbox, List } from "antd";
import React from "react";
import { ShoppingListItem } from "../shared/ShoppingListItem";

export interface ShoppingListItemComponentProps {
  item: ShoppingListItem;
  onItemCheckedChange: (checked: boolean) => void;
  onItemDeleted: () => void;
}

export function ShoppingListItemComponent(props: ShoppingListItemComponentProps) {
  return (
    <List.Item
      key={props.item._id}
      style={{
        textDecoration: props.item.checked ? "line-through" : "none"
      }}
    >
      <Checkbox
        style={{ marginRight: "1em" }}
        checked={props.item.checked}
        onChange={event => props.onItemCheckedChange(event.target.checked)}
      />
      {props.item.name}
      <Button style={{ float: "right", border: "0px" }} onClick={props.onItemDeleted} data-testid="delete-item-btn">
        <DeleteFilled alt={"Eintrag entfernen"} />
      </Button>
    </List.Item>
  );
}
