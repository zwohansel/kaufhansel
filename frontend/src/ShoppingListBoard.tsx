import {
  BorderOutlined,
  CheckSquareOutlined,
  DeleteFilled,
  DeleteOutlined,
  ShoppingCartOutlined
} from "@ant-design/icons";
import { useMutation, useQuery } from "@apollo/react-hooks";
import { Button, Col, Modal, notification, PageHeader, Radio, Row, Spin, Tabs } from "antd";
import { ApolloError } from "apollo-client";
import React, { useEffect, useRef, useState } from "react";
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
import ShoppingListComponent, { ShoppingListFilter } from "./ShoppingListComponent";
import { ShoppingListItem } from "./ShoppingListItem";
import { groupBy } from "./utils";

const { TabPane } = Tabs;

export interface ShoppingListBoardProps {
  onAuthenticationError?: () => void;
}

function ShoppingListBoard(props: ShoppingListBoardProps) {
  const handleApolloError = (error: ApolloError) => {
    if (props.onAuthenticationError && error.graphQLErrors.find(e => e?.extensions?.code === 401)) {
      props.onAuthenticationError();
    } else {
      notification.error({
        message: error.networkError ? "Uuups ein Fehler ist aufgetreten..." : error.name,
        description: error.networkError ? "Der Server antwortet nicht :(" : error.message
      });
    }
  };

  const { loading: loadingShoppingListItems, data: shoppingListData, refetch } = useQuery<ShoppingListItemsData>(
    GET_ITEMS,
    {
      onError: handleApolloError
    }
  );

  // When using the pollIntervall option of the query hook the query is sent twice every x seconds.
  // Therefore we roll our own polling mechanism.
  useEffect(() => {
    const interval = setInterval(() => {
      refetch();
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  const numberOfShoppingListItems = shoppingListData ? shoppingListData.shoppingListItems.length : 0;

  const newItemCreatedRef = useRef(false);
  const mainTabContentRef = useRef<HTMLDivElement>(null);

  const [createItem] = useMutation<CreateShoppingListItemData, { name: string }>(CREATE_ITEM, {
    onError: handleApolloError,
    update: (cache, { data }) => {
      const createdItem = data!.createShoppingListItem;
      const { shoppingListItems: cachedList } = cache.readQuery<ShoppingListItemsData>({ query: GET_ITEMS })!;
      cache.writeQuery<ShoppingListItemsData>({
        query: GET_ITEMS,
        data: {
          shoppingListItems: [...cachedList, createdItem]
        }
      });

      newItemCreatedRef.current = true;
    }
  });

  useEffect(() => {
    if (!newItemCreatedRef.current) {
      return;
    }

    if (mainTabContentRef.current === null) {
      return;
    }

    const items = mainTabContentRef.current.getElementsByClassName("shopping-list-item");

    if (items.length > 0) {
      items[items.length - 1].scrollIntoView({ behavior: "smooth" });
    }

    newItemCreatedRef.current = false;
  }, [numberOfShoppingListItems]);

  const [updateItem] = useMutation<UpdateItemData, UpdateItemVariables>(UPDATEM_ITEM, {
    onError: handleApolloError
  });

  const [deleteItem] = useMutation<DeleteShoppingListItemData, { id: string }>(DELETE_ITEM, {
    onError: handleApolloError,
    update: (cache, { data }) => {
      const deletedItemId = data!.deleteShoppingListItem;
      const { shoppingListItems: cachedList } = cache.readQuery<ShoppingListItemsData>({ query: GET_ITEMS })!;
      cache.writeQuery<ShoppingListItemsData>({
        query: GET_ITEMS,
        data: {
          shoppingListItems: cachedList.filter(item => item._id !== deletedItemId)
        }
      });
    }
  });

  const [clearList] = useMutation<ClearShoppingListData, {}>(CLEAR_LIST, {
    onError: handleApolloError,
    update: cache => {
      cache.writeQuery<ShoppingListItemsData>({
        query: GET_ITEMS,
        data: {
          shoppingListItems: []
        }
      });
    }
  });

  const createNewItem = async (name: string) => {
    await createItem({ variables: { name } });
  };

  const shoppingList = shoppingListData?.shoppingListItems || [];

  const itemsGroupedByAssignee = groupBy(
    shoppingList.filter(item => !!item.assignee),
    item => item.assignee,
    item => item
  );

  const assigneeShoppingLists = Array.from(itemsGroupedByAssignee.entries());

  const handleItemCheckedStateChange = (item: ShoppingListItem, checked: boolean) => {
    updateItem({
      variables: {
        id: item._id,
        state: checked
      },
      optimisticResponse: {
        updateShoppingListItem: {
          __typename: "ShoppingListItem",
          _id: item._id,
          assignee: item.assignee,
          name: item.name,
          checked: checked
        }
      }
    });
  };

  const handleItemDeleted = async (item: ShoppingListItem) => {
    await deleteItem({
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

    return `${itemsToBuy}/${activeList.length}`;
  };

  const [activeFilter, setActiveFilter] = useState(ShoppingListFilter.all);

  const renderToolbar = () => {
    return (
      <Row gutter={4}>
        <Col>{renderClearButton()}</Col>
        <Col>{renderListHeader()}</Col>
      </Row>
    );
  };

  const renderListHeader = () => {
    return (
      <Radio.Group
        buttonStyle="solid"
        size="small"
        value={activeFilter}
        onChange={event => setActiveFilter(event.target.value)}
      >
        <Radio.Button value={ShoppingListFilter.all}>
          <ShoppingCartOutlined></ShoppingCartOutlined>
        </Radio.Button>
        <Radio.Button value={ShoppingListFilter.checked}>
          <CheckSquareOutlined />
        </Radio.Button>
        <Radio.Button value={ShoppingListFilter.unchecked}>
          <BorderOutlined />
        </Radio.Button>
      </Radio.Group>
    );
  };

  const renderClearButton = () => {
    if (activeTabKey !== "main") {
      return <div></div>;
    }
    return (
      <Button
        danger
        type="default"
        size="small"
        onClick={() => {
          Modal.confirm({
            title: "Wollen Sie die Einkaufsliste wirklich leeren?",
            onOk: () => clearList(),
            okText: "Ja",
            cancelText: "Nein",
            icon: <DeleteFilled style={{ color: "#555555" }} />,
            okType: "danger"
          });
        }}
      >
        <DeleteOutlined />
      </Button>
    );
  };

  return (
    <div className="shopping-list-board">
      <PageHeader
        title={
          <span>
            <img className="kaufhansel-image" src="favicon.svg" />
            <span>Kaufhansel</span>
          </span>
        }
        subTitle={createSubTitle()}
        className="shopping-list-board-header"
        extra={renderToolbar()}
      />
      <Spin
        spinning={loadingShoppingListItems}
        tip="Wird aktualisiert..."
        wrapperClassName="shopping-list-board-spinner"
      >
        <Tabs
          defaultActiveKey="main"
          activeKey={activeTabKey}
          onChange={setActiveTabKey}
          className="shopping-list-board-tabs"
          animated={false}
        >
          <TabPane tab="Alle" key="main">
            <div ref={mainTabContentRef} className="shopping-list-board-main-tab-content">
              <EditableShoppingListComponent
                shoppingList={shoppingList}
                filter={activeFilter}
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
                onCreateNewItem={createNewItem}
              />
            </div>
          </TabPane>

          {assigneeShoppingLists.map(([assignee, assigneeShoppingList]) => {
            return (
              <TabPane tab={assignee} key={assignee}>
                <ShoppingListComponent
                  className="shopping-list-board-readonly-list"
                  shoppingList={assigneeShoppingList}
                  filter={activeFilter}
                  onItemCheckedChange={handleItemCheckedStateChange}
                  onItemDeleted={handleItemDeleted}
                />
              </TabPane>
            );
          })}
        </Tabs>
      </Spin>
    </div>
  );
}

export default ShoppingListBoard;
