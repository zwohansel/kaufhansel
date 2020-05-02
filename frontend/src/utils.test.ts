import { ShoppingListItem } from "./ShoppingListItem";
import { groupBy } from "./utils";

test("groupBy", () => {
  const shoppingList: ShoppingListItem[] = [
    { _id: "0", assignee: "Claus", checked: false, name: "Käse" },
    { _id: "1", assignee: "Michael", checked: false, name: "Milch" },
    { _id: "2", assignee: "Michael", checked: false, name: "Butter" },
    { _id: "3", assignee: "Claus", checked: false, name: "Kaffee" }
  ];

  const groupedByAssignee = groupBy(
    shoppingList,
    item => item.assignee,
    item => item.name
  );

  const expectedMap = new Map([
    ["Claus", ["Käse", "Kaffee"]],
    ["Michael", ["Milch", "Butter"]]
  ]);

  expect(groupedByAssignee).toEqual(expectedMap);
});
