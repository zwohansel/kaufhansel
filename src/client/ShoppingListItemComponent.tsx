import { DeleteFilled } from "@ant-design/icons";
import { AutoComplete, Button, Checkbox, List } from "antd";
import React, { useState } from "react";
import { ShoppingListItem } from "../shared/ShoppingListItem";
import { unique } from "../shared/utils";

export interface ShoppingListItemComponentProps {
  item: ShoppingListItem;
  assigneeCandidates: string[];
  onItemCheckedChange: (checked: boolean) => void;
  onItemDeleted: () => void;
  onItemAssigneeChange: (assignee: string) => void;
}

export function ShoppingListItemComponent(props: ShoppingListItemComponentProps) {
  const [newAssigneeName, setNewAssigneeName] = useState(props.item.assignee);

  const assigneeCandidates = unique(props.assigneeCandidates.filter(e => e.startsWith(newAssigneeName) && e !== ""));

  const selectNewAssignee = () => {
    if (newAssigneeName !== props.item.assignee) {
      console.log(newAssigneeName, " ", props.item.assignee);
      props.onItemAssigneeChange(newAssigneeName);
    }
  };

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

      {props.item.assignee ? " kauft" : ""}

      <AutoComplete
        defaultActiveFirstOption={true}
        value={newAssigneeName}
        onChange={setNewAssigneeName}
        onSelect={selectNewAssignee}
        onInputKeyDown={event => {
          if (event.keyCode === 13) {
            event.currentTarget.blur();
          }
        }}
        onBlur={selectNewAssignee}
        placeholder={"Wer kauf das?"}
        style={{ width: 200 }}
        options={assigneeCandidates.map(value => {
          return { value };
        })}
        bordered={false}
        size={"small"}
      ></AutoComplete>
      <Button style={{ float: "right", border: "0px" }} onClick={props.onItemDeleted} data-testid="delete-item-btn">
        <DeleteFilled alt={"Eintrag entfernen"} />
      </Button>
    </List.Item>
  );
}
