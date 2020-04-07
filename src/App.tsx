import { Button, Checkbox, Input, List, PageHeader } from "antd";
import React, { useState } from "react";
import "./App.css";

interface ShoppingListItem {
  name: string;
  checked: boolean;
}

function ShoppingListApp() {
  const [shoppingList, setShoppingList] = useState<ShoppingListItem[]>([]);
  const [newItemName, setNewItemName] = useState<string>("");

  const createNewItem = () => {
    if (newItemName === "") {
      return;
    }

    setShoppingList([...shoppingList, { name: newItemName, checked: false }]);
    setNewItemName("");
  };

  return (
    <PageHeader title="Einkaufsliste">
      <List
        dataSource={shoppingList}
        renderItem={(item) => {
          return (
            <List.Item
              key={item.name}
              style={{
                textDecoration: item.checked ? "line-through" : "none",
              }}
            >
              <Checkbox
                style={{ marginRight: "1em" }}
                value={item.checked}
                onChange={(event) => {
                  const newList = shoppingList.map((e) => {
                    if (item.name === e.name) {
                      return { ...e, checked: event.target.checked };
                    }
                    return e;
                  });

                  setShoppingList(newList);
                }}
              />
              {item.name}
            </List.Item>
          );
        }}
      />
      <div>
        <div style={{ display: "inline-block", width: "80%" }}>
          <Input
            value={newItemName}
            onChange={(event) => setNewItemName(event.target.value)}
            onPressEnter={createNewItem}
          />
        </div>
        <div
          style={{ display: "inline-block", width: "20%", paddingLeft: "10px" }}
        >
          <Button
            type="primary"
            style={{ width: "100%" }}
            disabled={newItemName === ""}
            onClick={createNewItem}
          >
            Hinzufügen
          </Button>
        </div>
      </div>
    </PageHeader>
  );
}

export default ShoppingListApp;
