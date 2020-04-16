import "@testing-library/jest-dom";
import { fireEvent, render } from "@testing-library/react";
import React from "react";
import { ShoppingListItem } from "../shared/ShoppingListItem";
import { ShoppingListItemComponent } from "./ShoppingListItemComponent";

test("render unchecked shopping list item", () => {
  const item: ShoppingListItem = {
    _id: "1",
    name: "My Test Item",
    checked: false
  };

  const element = render(
    <ShoppingListItemComponent item={item} onItemCheckedChange={() => {}} onItemDeleted={() => {}} />
  );
  const itemText = element.getByText(/My Test Item/i);
  expect(itemText).toBeInTheDocument();

  const checkBox = element.getByRole("checkbox");
  expect(checkBox).toBeInTheDocument();
  expect(checkBox).not.toBeChecked();

  const deleteButton = element.getByRole("button");
  expect(deleteButton).toBeInTheDocument();
  expect(deleteButton).toBeEnabled();
});

test("render checked shopping list item", () => {
  const item: ShoppingListItem = {
    _id: "1",
    name: "My Test Item",
    checked: true
  };

  const element = render(
    <ShoppingListItemComponent item={item} onItemCheckedChange={() => {}} onItemDeleted={() => {}} />
  );

  const checkBox = element.getByRole("checkbox");
  expect(checkBox).toBeChecked();
});

test("click unchecked checkbox", () => {
  const item: ShoppingListItem = {
    _id: "1",
    name: "My Test Item",
    checked: false
  };

  const handleItemChecked = jest.fn();

  const element = render(
    <ShoppingListItemComponent item={item} onItemCheckedChange={handleItemChecked} onItemDeleted={() => {}} />
  );

  const checkBox = element.getByRole("checkbox");
  fireEvent.click(checkBox);
  expect(handleItemChecked).toBeCalledTimes(1);
  expect(handleItemChecked).toHaveBeenCalledWith<[boolean]>(true);
});

test("click checked checkbox", () => {
  const item: ShoppingListItem = {
    _id: "1",
    name: "My Test Item",
    checked: true
  };

  const handleItemChecked = jest.fn();

  const element = render(
    <ShoppingListItemComponent item={item} onItemCheckedChange={handleItemChecked} onItemDeleted={() => {}} />
  );

  const checkBox = element.getByRole("checkbox");
  fireEvent.click(checkBox);
  expect(handleItemChecked).toBeCalledTimes(1);
  expect(handleItemChecked).toHaveBeenCalledWith<[boolean]>(false);
});

test("click delete button", () => {
  const item: ShoppingListItem = {
    _id: "1",
    name: "My Test Item",
    checked: false
  };

  const handleItemDeleted = jest.fn();

  const element = render(
    <ShoppingListItemComponent item={item} onItemCheckedChange={() => {}} onItemDeleted={handleItemDeleted} />
  );

  const deleteBtn = element.getByRole("button");
  fireEvent.click(deleteBtn);
  expect(handleItemDeleted).toBeCalledTimes(1);
});
