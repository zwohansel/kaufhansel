import { DeleteFilled } from "@ant-design/icons";
import { useMutation, useQuery } from "@apollo/react-hooks";
import { Button, Input, notification, Popconfirm, Spin } from "antd";
import { ApolloError, gql } from "apollo-boost";
import produce from "immer";
import React, { useState } from "react";
import { ShoppingListItem } from "../shared/ShoppingListItem";
import ShoppingListListComponent from "./ShoppingListListComponent";

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
      assignee
    }
  }
`;

export const CREATE_ITEM = gql`
  mutation createShoppingListItem($name: String!) {
    createShoppingListItem(name: $name) {
      _id
      name
      checked
      assignee
    }
  }
`;

export interface CreateShoppingListItemData {
  createShoppingListItem: ShoppingListItem;
}

export const DELETE_ITEM = gql`
  mutation deleteItem($id: ID!) {
    deleteShoppingListItem(id: $id)
  }
`;

export interface DeleteShoppingListItemData {
  deleteShoppingListItem: string;
}

export const UPDATEM_ITEM = gql`
  mutation updateItem($id: ID!, $state: Boolean, $assignee: String) {
    updateShoppingListItem(id: $id, state: $state, assignee: $assignee) {
      _id
      name
      checked
      assignee
    }
  }
`;

export interface UpdateItemData {
  updateShoppingListItem: ShoppingListItem;
}

export interface UpdateItemVariables {
  id: string;
  state?: boolean;
  assignee?: string;
}

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
  const [shoppingList, setShoppingList] = useState<ShoppingListItem[]>([]);
  const [newItemName, setNewItemName] = useState<string>("");

  const { loading: loadingShoppingListItems } = useQuery<ShoppingListItemsData>(GET_ITEMS, {
    onError: showApolloError,
    onCompleted: data => setShoppingList(data.shoppingListItems)
  });

  const [createItem, { loading: creatingItem }] = useMutation<CreateShoppingListItemData, { name: string }>(
    CREATE_ITEM,
    {
      onError: showApolloError,
      onCompleted: data =>
        setShoppingList(produce((draft: ShoppingListItem[]) => draft.concat(data.createShoppingListItem)))
    }
  );

  const [updateItem] = useMutation<UpdateItemData, UpdateItemVariables>(UPDATEM_ITEM, {
    onError: showApolloError,
    onCompleted: data =>
      setShoppingList(
        produce((draft: ShoppingListItem[]) =>
          draft.map(item => {
            if (item._id === data.updateShoppingListItem._id) {
              return data.updateShoppingListItem;
            }
            return item;
          })
        )
      )
  });

  const assigneeCandidates: string[] = shoppingList.map(item => item.assignee);

  const [deleteItem] = useMutation<DeleteShoppingListItemData, { id: string }>(DELETE_ITEM, {
    onError: showApolloError,
    onCompleted: data =>
      setShoppingList(
        produce((draft: ShoppingListItem[]) => draft.filter(item => item._id !== data.deleteShoppingListItem))
      )
  });

  const [clearList] = useMutation<ClearShoppingListData, {}>(CLEAR_LIST, {
    onError: showApolloError,
    onCompleted: () => setShoppingList([])
  });

  const createNewItem = async () => {
    if (newItemName === "") {
      return;
    }

    await createItem({ variables: { name: newItemName } });

    setNewItemName("");
  };

  return (
    <div>
      <Spin spinning={loadingShoppingListItems} tip="Wird aktualisiert...">
        <ShoppingListListComponent
          shoppingList={shoppingList}
          assigneeCandidates={assigneeCandidates}
          onItemAssigneeChange={(item, assignee) => {
            updateItem({
              variables: {
                id: item._id,
                assignee: assignee
              }
            });
          }}
          onItemCheckedChange={(item, checked) => {
            updateItem({
              variables: {
                id: item._id,
                state: checked
              }
            });
          }}
          onItemDeleted={item => {
            deleteItem({
              variables: {
                id: item._id
              }
            });
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
    </div>
  );
}

export default ShoppingListComponent;
