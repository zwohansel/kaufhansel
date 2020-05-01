import { useMutation, useQuery } from "@apollo/react-hooks";
import { notification, PageHeader, Spin, Tabs } from "antd";
import { ApolloError } from "apollo-boost";
import produce from "immer";
import React, { useState } from "react";
import { ShoppingListItem } from "../shared/ShoppingListItem";
import EditableShoppingListComponent from "./EditableShoppingListComponent";
import {
  ClearShoppingListData,
  CLEAR_LIST,
  CreateShoppingListItemData,
  CREATE_ITEM,
  DeleteShoppingListItemData,
  DELETE_ITEM,
  GET_ITEMS,
  ShoppingListItemsData,
  UpdateItemData,
  UpdateItemVariables,
  UPDATEM_ITEM
} from "./GraphQLDefinitions";
import ShoppingListComponent from "./ShoppingListComponent";

const { TabPane } = Tabs;

function showApolloError(error: ApolloError) {
  notification.error({
    message: error.name,
    description: error.message
  });
}

function ShoppingListBoard() {
  const [shoppingList, setShoppingList] = useState<ShoppingListItem[]>([]);

  const { loading: loadingShoppingListItems } = useQuery<ShoppingListItemsData>(GET_ITEMS, {
    onError: showApolloError,
    onCompleted: data => setShoppingList(data.shoppingListItems)
  });

  const [createItem] = useMutation<CreateShoppingListItemData, { name: string }>(CREATE_ITEM, {
    onError: showApolloError,
    onCompleted: data =>
      setShoppingList(produce((draft: ShoppingListItem[]) => draft.concat(data.createShoppingListItem)))
  });

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

  const createNewItem = async (name: string) => {
    await createItem({ variables: { name } });
  };

  return (
    <PageHeader title="Einkaufsliste">
      <Spin spinning={loadingShoppingListItems} tip="Wird aktualisiert...">
        <Tabs defaultActiveKey="main">
          <TabPane tab="Gesamte Einkaufsliste" key="main">
            <EditableShoppingListComponent
              shoppingList={shoppingList}
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
              onDeleteAllItems={() => clearList()}
              onCreateNewItem={createNewItem}
            />
          </TabPane>
          <TabPane tab="Tab 2" key="tab2">
            <ShoppingListComponent
              shoppingList={[]}
              assigneeCandidates={[]}
              onItemAssigneeChange={() => {}}
              onItemCheckedChange={() => {}}
              onItemDeleted={() => {}}
            />
          </TabPane>
        </Tabs>
      </Spin>
    </PageHeader>
  );
}

export default ShoppingListBoard;
