import { Button, Input, List, PageHeader } from "antd";
import React, { useState } from "react";
import "./App.css";

function ShoppingListApp() {
  const [shoppingList, setShoppingList] = useState<string[]>([]);
  const [newItem, setNewItem] = useState<string>("");

  return (
    <PageHeader title="Einkaufsliste">
      <List
        dataSource={shoppingList}
        renderItem={(item) => {
          return <List.Item key={item}>{item}</List.Item>;
        }}
      />
      <div>
        <div style={{ display: "inline-block", width: "80%" }}>
          <Input
            value={newItem}
            onChange={(event) => setNewItem(event.target.value)}
          />
        </div>
        <div
          style={{ display: "inline-block", width: "20%", paddingLeft: "10px" }}
        >
          <Button
            type="primary"
            style={{ width: "100%" }}
            disabled={newItem === ""}
            onClick={() => {
              setShoppingList([...shoppingList, newItem]);
              setNewItem("");
            }}
          >
            Hinzufügen
          </Button>
        </div>
      </div>
    </PageHeader>
  );
}

export default ShoppingListApp;
