import { DeleteFilled } from "@ant-design/icons";
import { AutoComplete, Button, Checkbox, List } from "antd";
import React, { useState } from "react";
import { ShoppingListItem } from "./ShoppingListItem";
import { unique } from "./utils";

export interface ShoppingListItemComponentProps {
  item: ShoppingListItem;
  assigneeCandidates?: string[];
  onItemCheckedChange: (checked: boolean) => void;
  onItemDeleted: () => Promise<void>;
  onItemAssigneeChange?: (assignee: string) => void;
}

export function ShoppingListItemComponent(props: ShoppingListItemComponentProps) {
  const [newAssigneeName, setNewAssigneeName] = useState(props.item.assignee);

  const assigneeCandidates = props.assigneeCandidates
    ? unique(props.assigneeCandidates.filter(e => e.startsWith(newAssigneeName) && e !== ""))
    : [];

  const selectNewAssignee = () => {
    if (props.onItemAssigneeChange && newAssigneeName !== props.item.assignee) {
      props.onItemAssigneeChange(newAssigneeName);
    }
  };

  const [deletingItem, setDeletingItem] = useState(false);

  return (
    <List.Item
      className="shopping-list-item"
      key={props.item._id}
      style={{
        textDecoration: props.item.checked ? "line-through" : "none"
      }}
      onClick={() => props.onItemCheckedChange(!props.item.checked)}
      actions={[
        <Button
          key="delete-item-btn"
          type="dashed"
          size="small"
          loading={deletingItem}
          onClick={async e => {
            e.stopPropagation();
            setDeletingItem(true);
            await props.onItemDeleted();
            setDeletingItem(false);
          }}
          data-testid="delete-item-btn"
          className="delete-item-btn"
        >
          {deletingItem ? <div /> : <DeleteFilled alt={"Eintrag entfernen"} />}
        </Button>
      ]}
    >
      <Checkbox
        style={{ marginRight: "1em" }}
        checked={props.item.checked}
        onChange={event => props.onItemCheckedChange(event.target.checked)}
      />
      {props.item.name}

      {props.assigneeCandidates && props.item.assignee ? " kauft" : ""}
      {props.assigneeCandidates && (
        <AutoComplete
          defaultActiveFirstOption={true}
          value={newAssigneeName}
          onChange={setNewAssigneeName}
          onSelect={selectNewAssignee}
          onClick={e => {
            e.stopPropagation();
          }}
          onInputKeyDown={event => {
            if (event.keyCode === 13) {
              selectNewAssignee();
            }
          }}
          onBlur={selectNewAssignee}
          placeholder={"Wer kauf das?"}
          options={assigneeCandidates.map(value => {
            return { value };
          })}
          bordered={false}
          size={"small"}
          style={{ minWidth: "30%" }}
        ></AutoComplete>
      )}
    </List.Item>
  );
}
