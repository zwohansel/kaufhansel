import { DeleteFilled } from "@ant-design/icons";
import { Affix, Button, Input, Popconfirm } from "antd";
import React, { useState } from "react";
import ShoppingListComponent from "./ShoppingListComponent";
import { ShoppingListItem } from "./ShoppingListItem";

export interface EditableShoppingListComponentProps {
  shoppingList: ShoppingListItem[];
  onItemCheckedChange: (item: ShoppingListItem, checked: boolean) => void;
  onItemDeleted: (item: ShoppingListItem) => void;
  onItemAssigneeChange: (item: ShoppingListItem, assignee: string) => void;
  onCreateNewItem: (name: string) => Promise<void>;
  onDeleteAllItems: () => void;
}

function EditableShoppingListComponent(props: EditableShoppingListComponentProps) {
  const [newItemName, setNewItemName] = useState<string>("");
  const [creatingItem, setCreatingItem] = useState<boolean>(false);

  const assigneeCandidates: string[] = props.shoppingList.map(item => item.assignee);

  const createNewItem = async () => {
    if (newItemName === "") {
      return;
    }

    setCreatingItem(true);
    await props.onCreateNewItem(newItemName);
    setNewItemName("");
    setCreatingItem(false);
  };

  return (
    <div>
      <ShoppingListComponent
        shoppingList={props.shoppingList}
        assigneeCandidates={assigneeCandidates}
        onItemAssigneeChange={props.onItemAssigneeChange}
        onItemCheckedChange={props.onItemCheckedChange}
        onItemDeleted={props.onItemDeleted}
      />
      <Affix offsetBottom={0}>
        <div style={{ paddingTop: "10px", paddingBottom: "10px", background: "white", borderTop: "1px solid #f0f0f0" }}>
          <div style={{ display: "inline-block", width: "70%" }}>
            <Input
              value={newItemName}
              onChange={event => setNewItemName(event.target.value)}
              onPressEnter={createNewItem}
              disabled={creatingItem}
            />
          </div>
          <div style={{ display: "inline-block", width: "20%", paddingLeft: "10px" }}>
            <Button
              type="primary"
              style={{ width: "100%" }}
              disabled={newItemName === ""}
              onClick={createNewItem}
              loading={creatingItem}
            >
              Hinzufügen
            </Button>
          </div>
          <div style={{ display: "inline-block", width: "10%", paddingLeft: "10px" }}>
            <Popconfirm
              title="Wollen Sie die Einkaufsliste wirklich leeren?"
              onConfirm={props.onDeleteAllItems}
              okText="Ja"
              cancelText="Nein"
              icon={<DeleteFilled style={{ color: "#555555" }} />}
              okType="danger"
            >
              <Button style={{ width: "100%" }} danger type="primary">
                Liste leeren
              </Button>
            </Popconfirm>
          </div>
        </div>
      </Affix>
    </div>
  );
}

export default EditableShoppingListComponent;
