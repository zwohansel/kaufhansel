import { DeleteFilled } from "@ant-design/icons";
import { useMutation, useQuery } from "@apollo/react-hooks";
import { Button, Input, List, notification, PageHeader, Popconfirm, Spin } from "antd";
import { ApolloError, gql, MutationUpdaterFn } from "apollo-boost";
import React, { useState } from "react";
import { ShoppingListItem } from "../shared/ShoppingListItem";
import { ShoppingListItemComponent } from "./ShoppingListItemComponent";

function showApolloError(error: ApolloError) {
  notification.error({
    message: error.name,
    description: error.message
  });
}

export const GET_ITEMS = gql`
  {
    shoppingListItems {
      _id
      name
      checked
    }
  }
`;

export const CREATE_ITEM = gql`
  mutation createShoppingListItem($name: String!) {
    createShoppingListItem(name: $name) {
      _id
      name
      checked
    }
  }
`;

export interface CreateShoppingListItemData {
  createShoppingListItem: ShoppingListItem;
}

const updateShoppingListItems: MutationUpdaterFn<CreateShoppingListItemData> = (cache, { data }) => {
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
      shoppingListItems: queryData.shoppingListItems.concat(data.createShoppingListItem)
    }
  });
};

export const DELETE_ITEM = gql`
  mutation deleteItem($id: ID!) {
    deleteShoppingListItem(id: $id)
  }
`;

export interface DeleteShoppingListItemData {
  deleteShoppingListItem: string;
}

const deleteShoppingListItem: MutationUpdaterFn<DeleteShoppingListItemData> = (cache, { data }) => {
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
      shoppingListItems: queryData.shoppingListItems.filter(e => e._id !== data.deleteShoppingListItem)
    }
  });
};

export const SET_ITEM_CHECKED_STATE = gql`
  mutation setItemCheckedState($id: ID!, $state: Boolean!) {
    changeShoppingListItemCheckedState(id: $id, state: $state) {
      _id
      name
      checked
    }
  }
`;

export interface SetItemCheckedStateData {
  changeShoppingListItemCheckedState: ShoppingListItem;
}

export interface SetItemCheckedStateVariables {
  id: string;
  state: boolean;
}

const clearShoppingList: MutationUpdaterFn<ClearShoppingListData> = (cache, { data }) => {
  if (data?.clearShoppingList) {
    cache.writeQuery<ShoppingListItemsData>({
      query: GET_ITEMS,
      data: {
        shoppingListItems: []
      }
    });
  }
};

export const CLEAR_LIST = gql`
  mutation clearList {
    clearShoppingList
  }
`;

export interface ClearShoppingListData {
  clearShoppingList: boolean;
}

export interface ShoppingListItemsData {
  shoppingListItems: ShoppingListItem[];
}

function ShoppingListComponent() {
  const [newItemName, setNewItemName] = useState<string>("");

  const { data, loading: loadingShoppingListItems } = useQuery<ShoppingListItemsData>(GET_ITEMS, {
    onError: showApolloError
  });

  const shoppingList = data && data.shoppingListItems ? data.shoppingListItems : [];

  const [createItem, { loading: creatingItem }] = useMutation<CreateShoppingListItemData, { name: string }>(
    CREATE_ITEM,
    {
      onError: showApolloError,
      update: updateShoppingListItems
    }
  );

  const [setItemCheckedState] = useMutation<SetItemCheckedStateData, SetItemCheckedStateVariables>(
    SET_ITEM_CHECKED_STATE,
    {
      onError: showApolloError
    }
  );

  const [deleteItem] = useMutation<DeleteShoppingListItemData, { id: string }>(DELETE_ITEM, {
    onError: showApolloError,
    update: deleteShoppingListItem
  });

  const [clearList] = useMutation<ClearShoppingListData, {}>(CLEAR_LIST, {
    onError: showApolloError,
    update: clearShoppingList
  });

  const createNewItem = async () => {
    if (newItemName === "") {
      return;
    }

    await createItem({ variables: { name: newItemName } });

    setNewItemName("");
  };

  return (
    <PageHeader title="Einkaufsliste">
      <Spin spinning={loadingShoppingListItems} tip="Wird aktualisiert...">
        <List
          dataSource={shoppingList}
          renderItem={item => {
            return (
              <ShoppingListItemComponent
                item={item}
                onItemCheckedChange={checked => {
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
      </Spin>
      <div>
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
            onConfirm={() => clearList({})}
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
    </PageHeader>
  );
}

export default ShoppingListComponent;
