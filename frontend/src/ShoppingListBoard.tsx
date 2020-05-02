import { useMutation, useQuery } from "@apollo/react-hooks";
import { notification, PageHeader, Spin, Tabs } from "antd";
import { ApolloError } from "apollo-boost";
import produce from "immer";
import React, { useState } from "react";
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
import { ShoppingListItem } from "./ShoppingListItem";
import { groupBy } from "./utils";

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

  const itemsGroupedByAssignee = groupBy(
    shoppingList,
    item => item.assignee,
    item => item
  );

  const assigneeShoppingLists = Array.from(itemsGroupedByAssignee.entries());

  const handleItemCheckedStateChange = (item: ShoppingListItem, checked: boolean) => {
    updateItem({
      variables: {
        id: item._id,
        state: checked
      }
    });
  };

  const handleItemDeleted = (item: ShoppingListItem) => {
    deleteItem({
      variables: {
        id: item._id
      }
    });
  };

  const [activeTabKey, setActiveTabKey] = useState("main");

  const getActiveShoppingList = () => {
    const assigneeList = itemsGroupedByAssignee.get(activeTabKey);

    if (assigneeList) {
      return assigneeList;
    }

    return shoppingList;
  };

  const createSubTitle = () => {
    const activeList = getActiveShoppingList();

    const itemsToBuy = activeList.filter(item => !item.checked).length;

    const isMainTab = activeTabKey === "main";

    if (itemsToBuy === 0) {
      if (isMainTab) {
        return "Wow... ihr habt alles gekauft.";
      }
      return "Wow... du hast schon alles gekauft.";
    }

    if (itemsToBuy === 1) {
      if (isMainTab) {
        return "Nur noch ein Produkt muss gekauft werden. Ihr schafft das!";
      }
      return "Nur noch ein Produkt muss gekauft werden. Du schaffst das!";
    }

    if (isMainTab) {
      return `Ihr müsst noch ${activeList.filter(item => !item.checked).length} Produkte kaufen.`;
    }

    return `Du musst noch ${activeList.filter(item => !item.checked).length} Produkte kaufen.`;
  };

  return (
    <PageHeader title="Einkaufsliste" subTitle={createSubTitle()}>
      <Spin spinning={loadingShoppingListItems} tip="Wird aktualisiert...">
        <Tabs defaultActiveKey="main" activeKey={activeTabKey} onChange={setActiveTabKey}>
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
              onItemCheckedChange={handleItemCheckedStateChange}
              onItemDeleted={handleItemDeleted}
              onDeleteAllItems={() => clearList()}
              onCreateNewItem={createNewItem}
            />
          </TabPane>

          {assigneeShoppingLists.map(([assignee, assigneeShoppingList]) => {
            return (
              <TabPane tab={assignee} key={assignee}>
                <ShoppingListComponent
                  shoppingList={assigneeShoppingList}
                  onItemCheckedChange={handleItemCheckedStateChange}
                  onItemDeleted={handleItemDeleted}
                />
              </TabPane>
            );
          })}
        </Tabs>
      </Spin>
    </PageHeader>
  );
}

export default ShoppingListBoard;
