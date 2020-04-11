import { useMutation, useQuery } from "@apollo/react-hooks";
import { Button, Input, List, notification, PageHeader } from "antd";
import { ApolloError, gql, MutationUpdaterFn } from "apollo-boost";
import React, { useState } from "react";
import "./App.css";
import { ShoppingListItem } from "./ShoppingListItem";
import { ShoppingListItemComponent } from "./ShoppingListItemComponent";

function showApolloError(error: ApolloError) {
  notification.error({
    message: error.name,
    description: error.message
  });
}

const GET_ITEMS = gql`
  {
    shoppingListItems {
      _id
      name
      checked
    }
  }
`;

interface CreateShoppingListItemData {
  createShoppingListItem: ShoppingListItem;
}

const updateShoppingListItems: MutationUpdaterFn<CreateShoppingListItemData> = (
  cache,
  { data }
) => {
  if (!data?.createShoppingListItem) {
    return;
  }

  const queryData = cache.readQuery<ShoppingListItemsData>({
    query: GET_ITEMS
  });

  if (!queryData?.shoppingListItems) {
    return;
  }

  cache.writeQuery<ShoppingListItemsData>({
    query: GET_ITEMS,
    data: {
      shoppingListItems: queryData.shoppingListItems.concat(
        data.createShoppingListItem
      )
    }
  });
};

interface DeleteShoppingListItemData {
  deleteShoppingListItem: ShoppingListItem;
}

const deleteShoppingListItem: MutationUpdaterFn<DeleteShoppingListItemData> = (
  cache,
  { data }
) => {
  if (!data?.deleteShoppingListItem) {
    return;
  }

  const queryData = cache.readQuery<ShoppingListItemsData>({
    query: GET_ITEMS
  });

  if (!queryData?.shoppingListItems) {
    return;
  }

  cache.writeQuery<ShoppingListItemsData>({
    query: GET_ITEMS,
    data: {
      shoppingListItems: queryData.shoppingListItems.filter(
        (e) => e._id !== data.deleteShoppingListItem._id
      )
    }
  });
};

interface ShoppingListItemsData {
  shoppingListItems: ShoppingListItem[];
}

function ShoppingListApp() {
  const [newItemName, setNewItemName] = useState<string>("");

  const { data } = useQuery<ShoppingListItemsData>(GET_ITEMS, {
    onError: showApolloError
  });

  const shoppingList =
    data && data.shoppingListItems ? data.shoppingListItems : [];

  const [createItem, { loading: creatingItem }] = useMutation<
    CreateShoppingListItemData,
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
      onError: showApolloError,
      update: updateShoppingListItems
    }
  );

  const [setItemCheckedState] = useMutation<
    {
      changeShoppingListItemCheckedState: ShoppingListItem;
    },
    { id: string; state: boolean }
  >(
    gql`
      mutation setItemCheckedState($id: ID!, $state: Boolean!) {
        changeShoppingListItemCheckedState(id: $id, state: $state) {
          _id
          name
          checked
        }
      }
    `,
    {
      onError: showApolloError
    }
  );

  const [deleteItem] = useMutation<
    {
      deleteShoppingListItem: ShoppingListItem;
    },
    { id: string }
  >(
    gql`
      mutation deleteItem($id: ID!) {
        deleteShoppingListItem(id: $id) {
          _id
        }
      }
    `,
    {
      onError: showApolloError,
      update: deleteShoppingListItem
    }
  );

  const createNewItem = async () => {
    if (newItemName === "") {
      return;
    }

    await createItem({ variables: { name: newItemName } });

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
                setItemCheckedState({
                  variables: {
                    id: item._id,
                    state: checked
                  }
                });
              }}
              onItemDeleted={() => {
                deleteItem({
                  variables: {
                    id: item._id
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
            disabled={creatingItem}
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
            loading={creatingItem}
          >
            Hinzufügen
          </Button>
        </div>
      </div>
    </PageHeader>
  );
}

export default ShoppingListApp;
