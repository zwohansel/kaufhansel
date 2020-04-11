import { useMutation, useQuery } from "@apollo/react-hooks";
import { Button, Input, List, PageHeader } from "antd";
import { gql } from "apollo-boost";
import React, { useState } from "react";
import "./App.css";
import { ShoppingListItem } from "./ShoppingListItem";
import { ShoppingListItemComponent } from "./ShoppingListItemComponent";

const GET_ITEMS = gql`
  {
    shoppingListItems {
      _id
      name
      checked
    }
  }
`;

interface ShoppingListItemsData {
  shoppingListItems: ShoppingListItem[];
}

interface SingleShoppingListItemData {
  createShoppingListItem: ShoppingListItem;
}

function ShoppingListApp() {
  const [newItemName, setNewItemName] = useState<string>("");

  const { data } = useQuery<ShoppingListItemsData>(GET_ITEMS);

  const shoppingList =
    data && data.shoppingListItems ? data.shoppingListItems : [];

  const [createItem] = useMutation<
    SingleShoppingListItemData,
    { name: string }
  >(
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
      update(cache, { data }) {
        if (data?.createShoppingListItem) {
          const queryData = cache.readQuery<ShoppingListItemsData>({
            query: GET_ITEMS
          });

          if (queryData?.shoppingListItems) {
            cache.writeQuery<ShoppingListItemsData>({
              query: GET_ITEMS,
              data: {
                shoppingListItems: queryData.shoppingListItems.concat(
                  data.createShoppingListItem
                )
              }
            });
          }
        }
      }
    }
  );

  const [setItemCheckedState] = useMutation<
    SingleShoppingListItemData,
    { id: string; state: boolean }
  >(gql`
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
