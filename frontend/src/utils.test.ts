import { ShoppingListItem } from "./ShoppingListItem";
import { groupBy, omitTypename, omitTypenames, parseUserIdFromCookieString } from "./utils";

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

test("omitTypename", () => {
  const item: ShoppingListItem = {
    _id: "0",
    __typename: "ShoppingListItem",
    assignee: "",
    checked: false,
    name: "Test"
  };

  const itemWithoutTypename = omitTypename(item);

  expect(itemWithoutTypename).toEqual({
    _id: "0",
    assignee: "",
    checked: false,
    name: "Test"
  });
});

test("omitTypenames", () => {
  const items: ShoppingListItem[] = [
    {
      _id: "0",
      __typename: "ShoppingListItem",
      assignee: "",
      checked: false,
      name: "Test"
    },
    {
      _id: "1",
      __typename: "ShoppingListItem",
      assignee: "",
      checked: true,
      name: "Test 2"
    }
  ];

  const itemWithoutTypename = omitTypenames(items);

  expect(itemWithoutTypename).toEqual([
    {
      _id: "0",
      assignee: "",
      checked: false,
      name: "Test"
    },
    {
      _id: "1",
      assignee: "",
      checked: true,
      name: "Test 2"
    }
  ]);
});

test("parseUserIdFromCookieString", () => {
  expect(parseUserIdFromCookieString("SHOPPER_LOGGED_IN=12345")).toEqual("12345");
  expect(parseUserIdFromCookieString("SHOPPER_LOGGED_IN=12345;BLA=BLUB")).toEqual("12345");
  expect(parseUserIdFromCookieString("CHOCKITY=POK;SHOPPER_LOGGED_IN=12345;BLA=BLUB")).toEqual("12345");
  expect(parseUserIdFromCookieString("CHOCKITY=POK; SHOPPER_LOGGED_IN=12345; BLA=BLUB")).toEqual("12345");
  expect(parseUserIdFromCookieString("SHOPPER_LOGGED_IN= 12345 ;BLA= BLUB")).toEqual("12345");
  expect(parseUserIdFromCookieString("SHOPPER_LOGGED_IN = 12345 ;BLA = BLUB")).toEqual("12345");
  expect(parseUserIdFromCookieString("SHOPPER_LOGGEDIN=12345;BLA=BLUB")).toEqual("");
  expect(parseUserIdFromCookieString("SHOPPER_LOGGED_IN=;BLA=BLUB")).toEqual("");
  expect(parseUserIdFromCookieString("SHOPPER_LOGGED_IN=")).toEqual("");
});
