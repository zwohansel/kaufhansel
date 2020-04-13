import { ObjectID } from "mongodb";
import { MongoMemoryServer } from "mongodb-memory-server";
import { ShoppingListItem } from "../shared/ShoppingListItem";
import Database from "./database";

let mongodb: MongoMemoryServer;
let database: Database;

beforeEach(async () => {
  mongodb = new MongoMemoryServer();

  const uri = await mongodb.getUri();
  database = await Database.create(uri);
});

test("get items from empty shopping list", async () => {
  const items = await database.getShoppingListItems();
  expect(items).toEqual([]);
});

test("create item", async () => {
  const newItem = await database.createShoppingListItem("test_item");

  expect(newItem).toEqual(
    expect.objectContaining<ShoppingListItem>({ _id: expect.any(ObjectID), name: "test_item", checked: false })
  );
});

test("get items from non empty shopping list", async () => {
  await database.createShoppingListItem("item_1");
  await database.createShoppingListItem("item_2");
  await database.createShoppingListItem("item_3");

  const items = await database.getShoppingListItems();

  const sortedItemNames = items.map(i => i.name).sort();

  expect(sortedItemNames).toEqual(["item_1", "item_2", "item_3"]);
});

test("change item checked state", async () => {
  const item = await database.createShoppingListItem("item_1");

  const changedItem = await database.setShoppingListItemCheckedState(item._id.toString(), true);

  expect(changedItem?.checked).toEqual(true);
});

test("get item with changed checked state", async () => {
  const item = await database.createShoppingListItem("item_1");

  await database.setShoppingListItemCheckedState(item._id.toString(), true);

  const items = await database.getShoppingListItems();

  expect(items.map(i => i.checked)).toEqual([true]);
});

test("change item checked state of non existing item", async () => {
  const changedItem = await database.setShoppingListItemCheckedState(new ObjectID().toHexString(), true);

  expect(changedItem).toBeNull();

  const items = await database.getShoppingListItems();

  expect(items).toEqual([]);
});

test("delete item", async () => {
  await database.createShoppingListItem("item_1");
  const itemToDelete = await database.createShoppingListItem("item_2");

  const deleteResult = await database.deleteShoppingListItem(itemToDelete._id.toString());

  expect(deleteResult).toEqual(itemToDelete._id.toString());

  const items = await database.getShoppingListItems();

  expect(items.map(i => i.name)).toEqual(["item_1"]);
});

test("delete item that is not present", async () => {
  const id = new ObjectID().toHexString();
  const deleteResult = await database.deleteShoppingListItem(id);

  expect(deleteResult).toEqual(id);

  const items = await database.getShoppingListItems();

  expect(items).toEqual([]);
});

test("clear shopping list", async () => {
  await database.createShoppingListItem("item_1");
  await database.createShoppingListItem("item_2");
  await database.createShoppingListItem("item_3");

  await database.clearShoppingList();

  const items = await database.getShoppingListItems();

  expect(items).toEqual([]);
});

afterEach(async () => {
  if (database) {
    await database.close();
  }

  if (mongodb) {
    await mongodb.stop();
  }
});
