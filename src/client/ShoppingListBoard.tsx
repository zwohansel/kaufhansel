import React from "react";
import { Tabs, PageHeader } from "antd";
import EditableShoppingListComponent from "./EditableShoppingListComponent";
import ShoppingListComponent from "./ShoppingListComponent";

const { TabPane } = Tabs;

function ShoppingListBoard() {
  return (
    <PageHeader title="Einkaufsliste">
      <Tabs defaultActiveKey="main">
        <TabPane tab="Gesamte Einkaufsliste" key="main">
          <EditableShoppingListComponent />
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
    </PageHeader>
  );
}

export default ShoppingListBoard;
