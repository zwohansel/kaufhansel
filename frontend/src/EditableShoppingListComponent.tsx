import { Button, Col, Input, Row } from "antd";
import React, { useState } from "react";
import ShoppingListComponent, { ShoppingListFilter } from "./ShoppingListComponent";
import { ShoppingListItem } from "./ShoppingListItem";

export interface EditableShoppingListComponentProps {
  shoppingList: ShoppingListItem[];
  filter: ShoppingListFilter;
  onItemCheckedChange: (item: ShoppingListItem, checked: boolean) => void;
  onItemDeleted: (item: ShoppingListItem) => Promise<void>;
  onItemAssigneeChange: (item: ShoppingListItem, assignee: string) => void;
  onCreateNewItem: (name: string) => Promise<void>;
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
        filter={props.filter}
        assigneeCandidates={assigneeCandidates}
        onItemAssigneeChange={props.onItemAssigneeChange}
        onItemCheckedChange={props.onItemCheckedChange}
        onItemDeleted={props.onItemDeleted}
      />
      <div className="editable-shopping-list-component-controls">
        <Row gutter={[16, 8]}>
          <Col xs={20} sm={20} md={20} lg={20} xl={20}>
            <Input
              value={newItemName}
              onChange={event => setNewItemName(event.target.value)}
              onPressEnter={createNewItem}
              disabled={creatingItem}
            />
          </Col>
          <Col xs={0} sm={0} md={4} lg={4} xl={4}>
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

          <Col xs={4} sm={4} md={0} lg={0} xl={0}>
            <Button
              className="editable-shopping-list-small-add-button"
              type="primary"
              disabled={newItemName === ""}
              onClick={createNewItem}
              loading={creatingItem}
            >
              {creatingItem ? "" : "+"}
            </Button>
          </Col>
        </Row>
      </div>
    </div>
  );
}

export default EditableShoppingListComponent;
