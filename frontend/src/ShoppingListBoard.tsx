import {
  BorderOutlined,
  CheckSquareOutlined,
  CloseOutlined,
  DeleteFilled,
  DeleteOutlined,
  MenuOutlined,
  ShoppingCartOutlined,
  UsergroupDeleteOutlined
} from "@ant-design/icons";
import { useMutation, useQuery, useSubscription } from "@apollo/react-hooks";
import { Button, Col, Drawer, Menu, Modal, notification, PageHeader, Radio, Row, Spin, Tabs } from "antd";
import { ApolloError } from "apollo-client";
import React, { Fragment, useEffect, useRef, useState } from "react";
import EditableShoppingListComponent from "./EditableShoppingListComponent";
import {
  ClearShoppingListData,
  CLEAR_LIST,
  CreateShoppingListItemData,
  CREATE_ITEM,
  DeleteShoppingListItemData,
  DELETE_ITEM,
  GET_ITEMS,
  ShoppingListChangedData,
  ShoppingListChangedVariables,
  ShoppingListItemsData,
  SHOPPING_LIST_CHANGED,
  UpdateItemData,
  UpdateItemVariables,
  UPDATEM_ITEMS
} from "./GraphQLDefinitions";
import ShoppingListComponent, { ShoppingListFilter } from "./ShoppingListComponent";
import { ShoppingListItem } from "./ShoppingListItem";
import { groupBy, omitTypenames } from "./utils";

const { TabPane } = Tabs;

export interface ShoppingListBoardProps {
  userId: string;
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

  const { loading: loadingShoppingListItems, data: shoppingListData } = useQuery<ShoppingListItemsData>(GET_ITEMS, {
    onError: handleApolloError
  });

  const numberOfShoppingListItems = shoppingListData ? shoppingListData.shoppingListItems.length : 0;

  const newItemCreatedRef = useRef(false);
  const mainTabContentRef = useRef<HTMLDivElement>(null);

  const [createItem] = useMutation<CreateShoppingListItemData, { name: string }>(CREATE_ITEM, {
    onError: handleApolloError,
    update: (cache, { data }) => {
      const createdItem = data!.createShoppingListItem;
      const { shoppingListItems: cachedList } = cache.readQuery<ShoppingListItemsData>({ query: GET_ITEMS })!;

      newItemCreatedRef.current = true;

      if (cachedList.find(item => item._id === createdItem._id)) {
        return; // Item already added via subscription
      }

      cache.writeQuery<ShoppingListItemsData>({
        query: GET_ITEMS,
        data: {
          shoppingListItems: [...cachedList, createdItem]
        }
      });
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
  }, [numberOfShoppingListItems, newItemCreatedRef.current]);

  const [updateItems] = useMutation<UpdateItemData, UpdateItemVariables>(UPDATEM_ITEMS, {
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

  useSubscription<ShoppingListChangedData, ShoppingListChangedVariables>(SHOPPING_LIST_CHANGED, {
    onSubscriptionData: options => {
      if (!options.subscriptionData.data) {
        return;
      }

      const changeEvents = options.subscriptionData.data.shoppingListChanged;
      const { shoppingListItems: cachedList } = options.client.readQuery<ShoppingListItemsData>({
        query: GET_ITEMS
      })!;

      const updatedList = [...cachedList];

      for (const changeEvent of changeEvents) {
        const existingItemIndex = cachedList.findIndex(item => item._id === changeEvent.item._id);

        switch (changeEvent.type) {
          case "ITEM_CHANGED":
            updatedList[existingItemIndex] = changeEvent.item;
            break;

          case "ITEM_CREATED":
            if (existingItemIndex < 0) {
              updatedList.push(changeEvent.item);
            }
            break;

          case "ITEM_DELETED":
            if (existingItemIndex >= 0) {
              updatedList.splice(existingItemIndex, 1);
            }
            break;
        }
      }

      options.client.writeQuery<ShoppingListItemsData>({
        query: GET_ITEMS,
        data: {
          shoppingListItems: updatedList
        }
      });
    },
    variables: {
      userId: props.userId
    },
    skip: props.userId === ""
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

  const handleUpdateItems = (updatedItems: ShoppingListItem[]) => {
    updateItems({
      variables: {
        items: omitTypenames(updatedItems) // The ShoppingListItemUpdate must not have a __typename field
      },
      optimisticResponse: {
        updateShoppingListItems: updatedItems
      }
    });
  };

  const handleItemCheckedStateChange = (item: ShoppingListItem, checked: boolean) => {
    handleUpdateItems([{ ...item, checked }]);
  };

  const handleItemAssigneeChange = (item: ShoppingListItem, assignee: string) => {
    handleUpdateItems([{ ...item, assignee }]);
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
        <Col>{renderListHeader()}</Col>
        <Col>{renderMenuButton()}</Col>
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
        <Radio.Button value={ShoppingListFilter.all} data-testid="show-all-btn">
          <ShoppingCartOutlined></ShoppingCartOutlined>
        </Radio.Button>
        <Radio.Button value={ShoppingListFilter.checked} data-testid="show-checked-btn">
          <CheckSquareOutlined />
        </Radio.Button>
        <Radio.Button value={ShoppingListFilter.unchecked} data-testid="show-unchecked-btn">
          <BorderOutlined />
        </Radio.Button>
      </Radio.Group>
    );
  };

  const renderMenuButton = () => {
    return (
      <Button size="small" onClick={() => setShowMenu(true)} data-testid="menu-btn">
        <MenuOutlined />
      </Button>
    );
  };

  const [showMenu, setShowMenu] = useState(false);

  return (
    <Fragment>
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
                  onItemAssigneeChange={handleItemAssigneeChange}
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
      <Drawer visible={showMenu} closable={false} onClose={() => setShowMenu(false)}>
        <Menu mode="inline" selectable={false}>
          <Menu.Item
            onClick={() => {
              handleUpdateItems(
                shoppingList.map(item => {
                  return { ...item, checked: false };
                })
              );
              setShowMenu(false);
            }}
          >
            <BorderOutlined />
            Alles nochmal kaufen
          </Menu.Item>
          <Menu.Item
            onClick={() => {
              handleUpdateItems(
                shoppingList.map(item => {
                  return { ...item, assignee: "" };
                })
              );
              setShowMenu(false);
            }}
          >
            <UsergroupDeleteOutlined />
            Niemand kauft
          </Menu.Item>
          <Menu.Item
            onClick={() => {
              Modal.confirm({
                title: "Wollen Sie die Einkaufsliste wirklich leeren?",
                onOk: () => clearList(),
                okText: "Ja",
                cancelText: "Nein",
                icon: <DeleteFilled style={{ color: "#555555" }} />,
                okType: "danger"
              });
              setShowMenu(false);
            }}
          >
            <DeleteOutlined />
            Alles löschen...
          </Menu.Item>
          <Menu.Item onClick={() => setShowMenu(false)}>
            <CloseOutlined />
            Menü Schließen
          </Menu.Item>
        </Menu>
      </Drawer>
    </Fragment>
  );
}

export default ShoppingListBoard;
