import { MockedProvider, MockedResponse } from "@apollo/react-testing";
import "@testing-library/jest-dom";
import { fireEvent, render, waitFor } from "@testing-library/react";
import React from "react";
import { ShoppingListItem } from "../shared/ShoppingListItem";
import ShoppingListComponent, {
  ClearShoppingListData,
  CLEAR_LIST,
  CreateShoppingListItemData,
  CREATE_ITEM,
  DeleteShoppingListItemData,
  DELETE_ITEM,
  GET_ITEMS,
  SetItemCheckedStateData,
  SetItemCheckedStateVariables,
  SET_ITEM_CHECKED_STATE,
  ShoppingListItemsData
} from "./ShoppingListComponent";

function createShoppingListItemsQueryTestData(items: ShoppingListItem[]) {
  const shoppingListItemsData: ShoppingListItemsData = { shoppingListItems: items };

  const mock: MockedResponse = {
    request: {
      query: GET_ITEMS
    },
    result: {
      data: shoppingListItemsData
    }
  };
  return mock;
}

function createShoppingListItemCreateMutationTestData(item: ShoppingListItem) {
  const shoppingListItemData: CreateShoppingListItemData = { createShoppingListItem: item };

  const mock: MockedResponse = {
    request: {
      query: CREATE_ITEM,
      variables: { name: item.name }
    },
    result: {
      data: shoppingListItemData
    }
  };
  return mock;
}

function createShoppingListItemDeleteMutationTestData(id: string) {
  const deleteShoppingListItemData: DeleteShoppingListItemData = { deleteShoppingListItem: id };
  const mock: MockedResponse = {
    request: {
      query: DELETE_ITEM,
      variables: { id }
    },
    result: {
      data: deleteShoppingListItemData
    }
  };
  return mock;
}

function createShoppingListItemToggleItemCheckedStateTestData(item: ShoppingListItem) {
  const variables: SetItemCheckedStateVariables = { id: item._id, state: !item.checked };
  const data: SetItemCheckedStateData = { changeShoppingListItemCheckedState: { ...item, checked: !item.checked } };

  const mock: MockedResponse = {
    request: {
      query: SET_ITEM_CHECKED_STATE,
      variables
    },
    result: {
      data
    }
  };
  return mock;
}

function createShoppingListClearTestData() {
  const clearShoppingListData: ClearShoppingListData = { clearShoppingList: true };

  const mock: MockedResponse = {
    request: {
      query: CLEAR_LIST
    },
    result: {
      data: clearShoppingListData
    }
  };
  return mock;
}

it("empty shopping list", async () => {
  const element = render(
    <MockedProvider mocks={[createShoppingListItemsQueryTestData([])]} addTypename={false}>
      <ShoppingListComponent />
    </MockedProvider>
  );

  const itemText = await element.findByText(/No Data/);
  expect(itemText).toBeInTheDocument();
});

it("shopping list with items", async () => {
  const element = render(
    <MockedProvider
      mocks={[
        createShoppingListItemsQueryTestData([
          { _id: "id_1", name: "Seife", checked: false },
          { _id: "id_2", name: "Klopapier", checked: false }
        ])
      ]}
      addTypename={false}
    >
      <ShoppingListComponent />
    </MockedProvider>
  );

  const item1 = await element.findByText(/Seife/);
  expect(item1).toBeInTheDocument();

  const item2 = await element.findByText(/Klopapier/);
  expect(item2).toBeInTheDocument();
});

it("create shopping list item", async () => {
  const element = render(
    <MockedProvider
      mocks={[
        createShoppingListItemsQueryTestData([]),
        createShoppingListItemCreateMutationTestData({ _id: "id_1", name: "Margarine", checked: false })
      ]}
      addTypename={false}
    >
      <ShoppingListComponent />
    </MockedProvider>
  );

  const input = element.getByRole("textbox");
  fireEvent.change(input, { target: { value: "Margarine" } });

  const button = element.getByRole("button", { name: "Hinzufügen" });
  expect(button).toBeEnabled();
  fireEvent.click(button);

  await waitFor(() => expect(input).toHaveValue(""));

  const item1 = await element.findByText(/Margarine/);
  expect(item1).toBeInTheDocument();
});

it("remove shopping list item", async () => {
  const element = render(
    <MockedProvider
      mocks={[
        createShoppingListItemsQueryTestData([{ _id: "id_1", name: "Margarine", checked: false }]),
        createShoppingListItemDeleteMutationTestData("id_1")
      ]}
      addTypename={false}
    >
      <ShoppingListComponent />
    </MockedProvider>
  );

  const button = await element.findByTestId("delete-item-btn");
  fireEvent.click(button);

  const itemText = await element.findByText(/No Data/);
  expect(itemText).toBeInTheDocument();
});

it("set item checked state", async () => {
  const testItem: ShoppingListItem = { _id: "id_1", name: "Margarine", checked: false };
  (testItem as any).__typename = "ShoppingListItem"; // Required for this test... see below

  const element = render(
    <MockedProvider
      mocks={[
        createShoppingListItemsQueryTestData([testItem]),
        createShoppingListItemToggleItemCheckedStateTestData(testItem)
      ]}
      addTypename={true} // Otherwise the GET_ITEMS query is not updated
    >
      <ShoppingListComponent />
    </MockedProvider>
  );

  const checkbox = await element.findByRole("checkbox");

  expect(checkbox).not.toBeChecked();

  fireEvent.click(checkbox);

  await waitFor(() => {
    expect(checkbox).toBeChecked();
  });
});

it("clear shopping list", async () => {
  const element = render(
    <MockedProvider
      mocks={[
        createShoppingListItemsQueryTestData([
          { _id: "id_1", name: "Seife", checked: false },
          { _id: "id_2", name: "Klopapier", checked: false }
        ]),
        createShoppingListClearTestData()
      ]}
      addTypename={false}
    >
      <ShoppingListComponent />
    </MockedProvider>
  );

  const item = await element.findByText(/Seife/);
  expect(item).toBeInTheDocument();

  const clearAllBtn = element.getByRole("button", { name: "Liste leeren" });
  fireEvent.click(clearAllBtn);

  const confirmBtn = await element.findByText("Ja");
  fireEvent.click(confirmBtn);

  const itemText = await element.findByText(/No Data/);
  expect(itemText).toBeInTheDocument();
});
