import { Button, Input, List, PageHeader } from "antd";
import React, { useEffect, useState } from "react";
import "./App.css";
import { ShoppingListItem } from "./ShoppingListItem";
import { ShoppingListItemComponent } from "./ShoppingListItemComponent";

function ShoppingListApp() {
  const [shoppingList, setShoppingList] = useState<ShoppingListItem[]>([]);
  const [newItemName, setNewItemName] = useState<string>("");

  useEffect(() => {
    fetch("api/shoppingList")
      .then((response) => response.json())
      .then((data) => setShoppingList(data));
  }, []);

  const createNewItem = () => {
    if (newItemName === "") {
      return;
    }

    const newItem: ShoppingListItem = { name: newItemName, checked: false };

    fetch("api/shoppingListItem", {
      method: "POST",
      body: JSON.stringify(newItem),
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((response) => response.json())
      .then((newItemFromServer) =>
        setShoppingList([...shoppingList, newItemFromServer])
      );

    setNewItemName("");
  };

  return (
    <PageHeader title="Einkaufsliste">
      <List
        dataSource={shoppingList}
        renderItem={(item) => {
          return (
            <ShoppingListItemComponent
              item={item}
              onItemCheckedChange={(checked) => {
                const newList = shoppingList.map((e) => {
                  if (item.name === e.name) {
                    return { ...e, checked: checked };
                  }
                  return e;
                });

                setShoppingList(newList);
              }}
            />
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
