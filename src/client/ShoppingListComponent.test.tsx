import "@testing-library/jest-dom";
import { MockedProvider, MockedResponse } from "@apollo/react-testing";
import ShoppingListComponent, {
  GET_ITEMS,
  CREATE_ITEM,
  ShoppingListItemsData,
  CreateShoppingListItemData
} from "./ShoppingListComponent";
import { render, fireEvent, waitFor } from "@testing-library/react";
import React from "react";
import { ShoppingListItem } from "../shared/ShoppingListItem";

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
