import { useMutation, useQuery } from "@apollo/react-hooks";
import { Button, Input, List, PageHeader } from "antd";
import { gql } from "apollo-boost";
import React, { useState } from "react";
import "./App.css";
import { ShoppingListItem } from "./ShoppingListItem";
import { ShoppingListItemComponent } from "./ShoppingListItemComponent";

function ShoppingListApp() {
  // const [shoppingList, setShoppingList] = useState<ShoppingListItem[]>([]);
  const [newItemName, setNewItemName] = useState<string>("");

  const GET_ITEMS = gql`
    {
      shoppingListItems {
        _id
        name
        checked
      }
    }
  `;

  const { data, loading } = useQuery(GET_ITEMS);

  const shoppingList: ShoppingListItem[] = loading
    ? []
    : data.shoppingListItems;

  const [createItem] = useMutation(
    gql`
      mutation createShoppingListItem($name: String!) {
        createShoppingListItem(name: $name) {
          _id
          name
          checked
        }
      }
    `,
    {
      update(cache, { data: { createShoppingListItem } }) {
        const data = cache.readQuery({ query: GET_ITEMS }) as any;

        console.log(createShoppingListItem);

        cache.writeQuery({
          query: GET_ITEMS,
          data: {
            shoppingListItems: data.shoppingListItems.concat(
              createShoppingListItem
            )
          }
        });
      }
    }
  );

  const [setItemCheckedState] = useMutation(gql`
    mutation setItemCheckedState($id: ID!, $state: Boolean!) {
      changeShoppingListItemCheckedState(id: $id, state: $state) {
        _id
        name
        checked
      }
    }
  `);

  const createNewItem = async () => {
    if (newItemName === "") {
      return;
    }

    createItem({ variables: { name: newItemName } });

    setNewItemName("");
  };

  // const showError = () => {
  //   notification.error({
  //     message: "NOOOOOOOO!!!!!",
  //     description: "Did not work :("
  //   });
  // };

  return (
    <PageHeader title="Einkaufsliste">
      <List
        dataSource={shoppingList}
        renderItem={(item) => {
          return (
            <ShoppingListItemComponent
              item={item}
              onItemCheckedChange={async (checked) => {
                setItemCheckedState({
                  variables: {
                    id: item._id,
                    state: checked
                  }
                });
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
