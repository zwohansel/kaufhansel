import "@testing-library/jest-dom";
import { render } from "@testing-library/react";
import React from "react";
import { ShoppingListItem } from "./ShoppingListItem";
import { ShoppingListItemComponent } from "./ShoppingListItemComponent";

test("render shopping list item", () => {
  const item: ShoppingListItem = {
    _id: "1",
    name: "My Test Item",
    checked: false
  };

  const { getByText } = render(
    <ShoppingListItemComponent
      item={item}
      onItemCheckedChange={() => {}}
      onItemDeleted={() => {}}
    />
  );
  const itemText = getByText(/My Test Item/i);
  expect(itemText).toBeInTheDocument();
});
