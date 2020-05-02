import "@testing-library/jest-dom";
import { fireEvent, render } from "@testing-library/react";
import React from "react";
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
      onItemDeleted={() => {}}
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
      onItemDeleted={() => {}}
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
      onItemDeleted={() => {}}
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
      onItemDeleted={() => {}}
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
      onItemDeleted={() => {}}
      onItemAssigneeChange={() => {}}
    />
  );

  const assigneeInput = element.getByDisplayValue("Mooncake");

  expect(assigneeInput).toBeInTheDocument();
});

test("set assignee after focus lost", () => {
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
      onItemDeleted={() => {}}
      onItemAssigneeChange={handleAssigneeChange}
    />
  );

  const assigneeInput = element.getByRole("combobox");

  fireEvent.change(assigneeInput, { target: { value: "Mooncookie" } });
  fireEvent.blur(assigneeInput);

  expect(handleAssigneeChange).toBeCalledWith("Mooncookie");
});

test("set assignee after enter pressed", () => {
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
      onItemDeleted={() => {}}
      onItemAssigneeChange={handleAssigneeChange}
    />
  );

  const assigneeInput = element.getByRole("combobox");

  fireEvent.change(assigneeInput, { target: { value: "Mooncookie" } });
  assigneeInput.focus();
  fireEvent.keyDown(assigneeInput, { key: "Enter", keyCode: 13, charCode: 13 });

  expect(handleAssigneeChange).toBeCalledWith("Mooncookie");
});

test("do not set assignee if unchanged", () => {
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
      assigneeCandidates={[]}
      onItemCheckedChange={() => {}}
      onItemDeleted={() => {}}
      onItemAssigneeChange={handleAssigneeChange}
    />
  );

  const assigneeInput = element.getByRole("combobox");

  fireEvent.change(assigneeInput, { target: { value: "Mooncookie" } });
  assigneeInput.focus();
  fireEvent.keyDown(assigneeInput, { key: "Enter", keyCode: 13, charCode: 13 });

  expect(handleAssigneeChange).not.toBeCalled();
});

test("render assignee candidates as options", async () => {
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
      onItemDeleted={() => {}}
      onItemAssigneeChange={handleAssigneeChange}
    />
  );

  const assigneeInput = element.getByRole("combobox");

  assigneeInput.focus();
  fireEvent.mouseDown(assigneeInput);

  const mooncakeOption = await element.findByRole("option", { name: "Mooncake" });
  expect(mooncakeOption).toBeInTheDocument();

  const mooncookieOption = await element.findByRole("option", { name: "Mooncookie" });
  expect(mooncookieOption).toBeInTheDocument();
});
