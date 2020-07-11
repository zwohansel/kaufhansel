import { MockedProvider, MockedResponse } from "@apollo/react-testing";
import "@testing-library/jest-dom";
import { act, fireEvent, render, waitFor } from "@testing-library/react";
import React from "react";
import wait from "waait";
import {
  ClearShoppingListData,
  CLEAR_LIST,
  CreateShoppingListItemData,
  CREATE_ITEM,
  DeleteShoppingListItemData,
  DELETE_ITEM,
  GET_ITEMS,
  ShoppingListItemsData,
  SHOPPING_LIST_CHANGED,
  UpdateItemData,
  UpdateItemVariables,
  UPDATEM_ITEMS
} from "./GraphQLDefinitions";
import "./matchMedia.mock";
import ShoppingListBoard from "./ShoppingListBoard";
import { ShoppingListItem } from "./ShoppingListItem";

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

function createShoppingListItemsChangedData() {
  const mock: MockedResponse = {
    request: {
      query: SHOPPING_LIST_CHANGED
    },
    result: {
      data: null
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
  const variables: UpdateItemVariables = { items: [{ ...item, checked: !item.checked }] };
  const data: UpdateItemData = { updateShoppingListItems: [{ ...item, checked: !item.checked }] };

  const mock: MockedResponse = {
    request: {
      query: UPDATEM_ITEMS,
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

beforeAll(() => {
  window.HTMLElement.prototype.scrollIntoView = jest.fn();
});

it("empty shopping list", async () => {
  const element = render(
    <MockedProvider
      mocks={[createShoppingListItemsQueryTestData([]), createShoppingListItemsChangedData()]}
      addTypename={false}
    >
      <ShoppingListBoard userId={""} />
    </MockedProvider>
  );

  await act(wait);

  const itemText = await element.findByText(/Kaufstu was!\?/);
  expect(itemText).toBeVisible();
});

it("shopping list with items", async () => {
  const element = render(
    <MockedProvider
      mocks={[
        createShoppingListItemsQueryTestData([
          { _id: "id_1", name: "Seife", checked: false, assignee: "" },
          { _id: "id_2", name: "Klopapier", checked: false, assignee: "" }
        ]),
        createShoppingListItemsChangedData()
      ]}
      addTypename={false}
    >
      <ShoppingListBoard userId={""} />
    </MockedProvider>
  );

  await act(wait);

  const item1 = await element.findByText(/Seife/);
  expect(item1).toBeVisible();

  const item2 = await element.findByText(/Klopapier/);
  expect(item2).toBeVisible();
});

it("create shopping list item", async () => {
  const element = render(
    <MockedProvider
      mocks={[
        createShoppingListItemsQueryTestData([]),
        createShoppingListItemCreateMutationTestData({ _id: "id_1", name: "Margarine", checked: false, assignee: "" }),
        createShoppingListItemsChangedData()
      ]}
      addTypename={false}
    >
      <ShoppingListBoard userId={""} />
    </MockedProvider>
  );

  await act(wait);

  const input = element.getByRole("textbox");
  fireEvent.change(input, { target: { value: "Margarine" } });

  const button = element.getByRole("button", { name: "Hinzufügen" });
  expect(button).toBeEnabled();
  fireEvent.click(button);

  await waitFor(() => expect(input).toHaveValue(""));

  const item1 = await element.findByText(/Margarine/);
  expect(item1).toBeVisible();
});

it("remove shopping list item", async () => {
  const element = render(
    <MockedProvider
      mocks={[
        createShoppingListItemsQueryTestData([{ _id: "id_1", name: "Margarine", checked: false, assignee: "" }]),
        createShoppingListItemDeleteMutationTestData("id_1"),
        createShoppingListItemsChangedData()
      ]}
      addTypename={false}
    >
      <ShoppingListBoard userId={""} />
    </MockedProvider>
  );

  await act(wait);

  const button = await element.findByTestId("delete-item-btn");
  fireEvent.click(button);

  const itemText = await element.findByText(/Kaufstu was!\?/);
  expect(itemText).toBeVisible();
});

it("set item checked state", async () => {
  const testItem: ShoppingListItem = {
    _id: "id_1",
    name: "Margarine",
    checked: false,
    assignee: "",
    __typename: "ShoppingListItem" // Apollos automatic cache update does not work without the typename
  };

  const element = render(
    <MockedProvider
      mocks={[
        createShoppingListItemsQueryTestData([testItem]),
        createShoppingListItemToggleItemCheckedStateTestData(testItem),
        createShoppingListItemsChangedData()
      ]}
      addTypename={true}
    >
      <ShoppingListBoard userId={""} />
    </MockedProvider>
  );

  await act(wait);

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
          { _id: "id_1", name: "Seife", checked: false, assignee: "" },
          { _id: "id_2", name: "Klopapier", checked: false, assignee: "" }
        ]),
        createShoppingListClearTestData(),
        createShoppingListItemsChangedData()
      ]}
      addTypename={false}
    >
      <ShoppingListBoard userId={""} />
    </MockedProvider>
  );

  await act(wait);

  const item = await element.findByText(/Seife/);
  expect(item).toBeVisible();

  const menuButton = await element.findByTestId("menu-btn");
  fireEvent.click(menuButton);

  const clearAllBtn = await element.findByRole("menuitem", { name: /Alles löschen.../ });
  fireEvent.click(clearAllBtn);

  const confirmBtn = await element.findByText("Ja");
  fireEvent.click(confirmBtn);

  const itemText = await element.findByText(/Kaufstu was!\?/);
  expect(itemText).toBeVisible();
});

it("create tab for each assignee", async () => {
  const element = render(
    <MockedProvider
      mocks={[
        createShoppingListItemsQueryTestData([
          { _id: "id_1", name: "Seife", checked: false, assignee: "Claus" },
          { _id: "id_2", name: "Klopapier", checked: false, assignee: "Michael" }
        ]),
        createShoppingListItemsChangedData()
      ]}
      addTypename={false}
    >
      <ShoppingListBoard userId={""} />
    </MockedProvider>
  );

  await act(wait);

  const clausTab = element.getByRole("tab", { name: "Claus" });
  expect(clausTab).toBeVisible();

  const michaelTab = element.getByRole("tab", { name: "Michael" });
  expect(michaelTab).toBeVisible();
});

it("show only checked items", async () => {
  const element = render(
    <MockedProvider
      mocks={[
        createShoppingListItemsQueryTestData([
          { _id: "id_1", name: "Seife", checked: true, assignee: "" },
          { _id: "id_2", name: "Klopapier", checked: false, assignee: "" }
        ]),
        createShoppingListItemsChangedData()
      ]}
      addTypename={false}
    >
      <ShoppingListBoard userId={""} />
    </MockedProvider>
  );

  await act(wait);

  await element.findByText(/Seife/);
  await element.findByText(/Klopapier/);

  const showCheckedBtn = element.getByTestId("show-checked-btn");
  fireEvent.click(showCheckedBtn);

  const seife = element.queryByText(/Seife/);
  expect(seife).toBeVisible();

  const klopapier = element.queryByText(/Klopapier/);
  expect(klopapier).toBeNull();
});

it("show only unchecked items", async () => {
  const element = render(
    <MockedProvider
      mocks={[
        createShoppingListItemsQueryTestData([
          { _id: "id_1", name: "Seife", checked: true, assignee: "" },
          { _id: "id_2", name: "Klopapier", checked: false, assignee: "" }
        ]),
        createShoppingListItemsChangedData()
      ]}
      addTypename={false}
    >
      <ShoppingListBoard userId={""} />
    </MockedProvider>
  );

  await act(wait);

  await element.findByText(/Seife/);
  await element.findByText(/Klopapier/);

  const showCheckedBtn = element.getByTestId("show-unchecked-btn");
  fireEvent.click(showCheckedBtn);

  const seife = element.queryByText(/Seife/);
  expect(seife).toBeNull();

  const klopapier = element.queryByText(/Klopapier/);
  expect(klopapier).toBeVisible();
});

it("show all items", async () => {
  const element = render(
    <MockedProvider
      mocks={[
        createShoppingListItemsQueryTestData([
          { _id: "id_1", name: "Seife", checked: true, assignee: "" },
          { _id: "id_2", name: "Klopapier", checked: false, assignee: "" }
        ]),
        createShoppingListItemsChangedData()
      ]}
      addTypename={false}
    >
      <ShoppingListBoard userId={""} />
    </MockedProvider>
  );

  await act(wait);

  await element.findByText(/Seife/);
  await element.findByText(/Klopapier/);

  const showCheckedBtn = element.getByTestId("show-unchecked-btn");
  fireEvent.click(showCheckedBtn);

  const showAllBtn = element.getByTestId("show-all-btn");
  fireEvent.click(showAllBtn);

  const seife = element.queryByText(/Seife/);
  expect(seife).toBeVisible();

  const klopapier = element.queryByText(/Klopapier/);
  expect(klopapier).toBeVisible();
});
