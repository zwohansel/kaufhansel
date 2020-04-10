import { Button, Input, List, notification, PageHeader } from "antd";
import produce from "immer";
import React, { useEffect, useState } from "react";
import "./App.css";
import { CheckedStateRequest } from "./CheckedStateRequest";
import { ShoppingListItem } from "./ShoppingListItem";
import { ShoppingListItemComponent } from "./ShoppingListItemComponent";

function ShoppingListApp() {
  const [shoppingList, setShoppingList] = useState<ShoppingListItem[]>([]);
  const [newItemName, setNewItemName] = useState<string>("");

  useEffect(() => {
    (async () => {
      const response = await fetch("api/shoppingList");

      if (!response.ok) {
        showError();
        return;
      }

      const data = await response.json();
      setShoppingList(data);
    })();
  }, []);

  const createNewItem = async () => {
    if (newItemName === "") {
      return;
    }

    const newItem: ShoppingListItem = { name: newItemName, checked: false };

    const response = await fetch("api/shoppingListItem", {
      method: "POST",
      body: JSON.stringify(newItem),
      headers: {
        "Content-Type": "application/json"
      }
    });

    if (!response.ok) {
      showError();
      return;
    }

    const newItemFromServer = await response.json();

    const newShoppingList = produce(shoppingList, (draft) => {
      draft.push(newItemFromServer);
    });

    setShoppingList(newShoppingList);
    setNewItemName("");
  };

  const showError = () => {
    notification.error({
      message: "NOOOOOOOO!!!!!",
      description: "Did not work :("
    });
  };

  return (
    <PageHeader title="Einkaufsliste">
      <List
        dataSource={shoppingList}
        renderItem={(item) => {
          return (
            <ShoppingListItemComponent
              item={item}
              onItemCheckedChange={async (checked) => {
                const request: CheckedStateRequest = {
                  state: checked
                };

                const response = await fetch(
                  `api/shoppingListItem/${item._id}/changeCheckedState`,
                  {
                    method: "PUT",
                    body: JSON.stringify(request),
                    headers: {
                      "Content-Type": "application/json"
                    }
                  }
                );

                if (response.ok) {
                  const newList = produce(shoppingList, (draft) => {
                    const checkedItem = draft.find((e) => e._id === item._id);

                    if (checkedItem) {
                      checkedItem.checked = checked;
                    }
                  });

                  setShoppingList(newList);
                } else {
                  showError();
                }
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
