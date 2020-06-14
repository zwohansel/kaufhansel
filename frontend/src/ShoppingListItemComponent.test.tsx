import "@testing-library/jest-dom";
import { fireEvent, render } from "@testing-library/react";
import React from "react";
import "./matchMedia.mock";
import { ShoppingListItem } from "./ShoppingListItem";
import { ShoppingListItemComponent } from "./ShoppingListItemComponent";

test("render unchecked shopping list item", () => {
  const item: ShoppingListItem = {
    _id: "1",
    name: "My Test Item",
    checked: false,
    assignee: ""
  };

  const element = render(
    <ShoppingListItemComponent
      item={item}
      assigneeCandidates={[]}
      onItemCheckedChange={() => {}}
      onItemDeleted={async () => {}}
      onItemAssigneeChange={() => {}}
    />
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
    checked: true,
    assignee: ""
  };

  const element = render(
    <ShoppingListItemComponent
      item={item}
      assigneeCandidates={[]}
      onItemCheckedChange={() => {}}
      onItemDeleted={async () => {}}
      onItemAssigneeChange={() => {}}
    />
  );

  const checkBox = element.getByRole("checkbox");
  expect(checkBox).toBeChecked();
});

test("click unchecked checkbox", () => {
  const item: ShoppingListItem = {
    _id: "1",
    name: "My Test Item",
    checked: false,
    assignee: ""
  };

  const handleItemChecked = jest.fn();

  const element = render(
    <ShoppingListItemComponent
      item={item}
      assigneeCandidates={[]}
      onItemCheckedChange={handleItemChecked}
      onItemDeleted={async () => {}}
      onItemAssigneeChange={() => {}}
    />
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
    checked: true,
    assignee: ""
  };

  const handleItemChecked = jest.fn();

  const element = render(
    <ShoppingListItemComponent
      item={item}
      assigneeCandidates={[]}
      onItemCheckedChange={handleItemChecked}
      onItemDeleted={async () => {}}
      onItemAssigneeChange={() => {}}
    />
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
    checked: false,
    assignee: ""
  };

  const handleItemDeleted = jest.fn();

  const element = render(
    <ShoppingListItemComponent
      item={item}
      assigneeCandidates={[]}
      onItemCheckedChange={() => {}}
      onItemDeleted={handleItemDeleted}
      onItemAssigneeChange={() => {}}
    />
  );

  const deleteBtn = element.getByRole("button");
  fireEvent.click(deleteBtn);
  expect(handleItemDeleted).toBeCalledTimes(1);
});

test("render assignee", () => {
  const item: ShoppingListItem = {
    _id: "1",
    name: "My Test Item",
    checked: false,
    assignee: "Mooncake"
  };

  const element = render(
    <ShoppingListItemComponent
      item={item}
      assigneeCandidates={[]}
      onItemCheckedChange={() => {}}
      onItemDeleted={async () => {}}
      onItemAssigneeChange={() => {}}
    />
  );

  const assigneeInput = element.getByText("Mooncake");

  expect(assigneeInput).toBeInTheDocument();
});

test("set assignee", async () => {
  const item: ShoppingListItem = {
    _id: "1",
    name: "My Test Item",
    checked: false,
    assignee: ""
  };

  const handleAssigneeChange = jest.fn();

  const element = render(
    <ShoppingListItemComponent
      item={item}
      assigneeCandidates={[]}
      onItemCheckedChange={() => {}}
      onItemDeleted={async () => {}}
      onItemAssigneeChange={handleAssigneeChange}
    />
  );

  const assigneeDisplay = element.getByText("Wer kauft das?");
  fireEvent.click(assigneeDisplay);

  const assigneeInput = await element.findByRole("textbox");
  fireEvent.change(assigneeInput, { target: { value: "Mooncookie" } });

  const confirmBtn = element.getByRole("button", { name: /Zuweisen/ });
  fireEvent.click(confirmBtn);

  expect(handleAssigneeChange).toBeCalledWith("Mooncookie");
});

test("select assignee", async () => {
  const item: ShoppingListItem = {
    _id: "1",
    name: "My Test Item",
    checked: false,
    assignee: ""
  };

  const handleAssigneeChange = jest.fn();

  const element = render(
    <ShoppingListItemComponent
      item={item}
      assigneeCandidates={["Mooncake", "Mooncookie"]}
      onItemCheckedChange={() => {}}
      onItemDeleted={async () => {}}
      onItemAssigneeChange={handleAssigneeChange}
    />
  );

  const assigneeDisplay = element.getByText("Wer kauft das?");
  fireEvent.click(assigneeDisplay);

  const assigneeItem = await element.findByText("Mooncake");
  fireEvent.click(assigneeItem);

  expect(handleAssigneeChange).toBeCalledWith("Mooncake");
});

test("remove assignee", async () => {
  const item: ShoppingListItem = {
    _id: "1",
    name: "My Test Item",
    checked: false,
    assignee: "Mooncookie"
  };

  const handleAssigneeChange = jest.fn();

  const element = render(
    <ShoppingListItemComponent
      item={item}
      assigneeCandidates={["Mooncookie"]}
      onItemCheckedChange={() => {}}
      onItemDeleted={async () => {}}
      onItemAssigneeChange={handleAssigneeChange}
    />
  );

  const assigneeDisplay = element.getByText("Mooncookie");
  fireEvent.click(assigneeDisplay);

  const removeBtn = element.getByRole("button", { name: /Niemand/ });
  fireEvent.click(removeBtn);

  expect(handleAssigneeChange).toBeCalledWith("");
});

test("do not change assignee", async () => {
  const item: ShoppingListItem = {
    _id: "1",
    name: "My Test Item",
    checked: false,
    assignee: "Mooncake"
  };

  const handleAssigneeChange = jest.fn();

  const element = render(
    <ShoppingListItemComponent
      item={item}
      assigneeCandidates={["Mooncake", "Mooncookie"]}
      onItemCheckedChange={() => {}}
      onItemDeleted={async () => {}}
      onItemAssigneeChange={handleAssigneeChange}
    />
  );

  const assigneeDisplay = element.getByText("Mooncake");
  fireEvent.click(assigneeDisplay);

  const removeBtn = element.getByRole("button", { name: /Egal/ });
  fireEvent.click(removeBtn);

  expect(handleAssigneeChange).not.toBeCalled();
});
