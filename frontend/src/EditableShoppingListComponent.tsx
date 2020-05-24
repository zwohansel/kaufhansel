import { DeleteFilled } from "@ant-design/icons";
import { Button, Col, Input, Popconfirm, Row } from "antd";
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
    <div className="editable-shopping-list-component">
      <ShoppingListComponent
        className="editable-shopping-list-component-list"
        shoppingList={props.shoppingList}
        assigneeCandidates={assigneeCandidates}
        onItemAssigneeChange={props.onItemAssigneeChange}
        onItemCheckedChange={props.onItemCheckedChange}
        onItemDeleted={props.onItemDeleted}
      />
      <div
        style={{ paddingTop: "10px", paddingBottom: "10px", background: "white", borderTop: "1px solid #f0f0f0" }}
        className="editable-shopping-list-component-controls"
      >
        <Row gutter={[16, 8]}>
          <Col xs={24} sm={24} md={15} lg={15} xl={15}>
            <Input
              value={newItemName}
              onChange={event => setNewItemName(event.target.value)}
              onPressEnter={createNewItem}
              disabled={creatingItem}
            />
          </Col>
          <Col xs={24} sm={24} md={5} lg={5} xl={5}>
            <Button
              type="primary"
              style={{ width: "100%" }}
              disabled={newItemName === ""}
              onClick={createNewItem}
              loading={creatingItem}
            >
              Hinzufügen
            </Button>
          </Col>
          <Col xs={24} sm={24} md={4} lg={4} xl={4}>
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
          </Col>
        </Row>
      </div>
    </div>
  );
}

export default EditableShoppingListComponent;
