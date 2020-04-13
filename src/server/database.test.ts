import * as mongoose from "mongoose";

import { ShoppingListItemBase } from "../shared/ShoppingListItem";


interface ShoppingListItemDocument
  extends ShoppingListItemBase,
    mongoose.Document {}

let ShoppingListItemModel: mongoose.Model<ShoppingListItemDocument, {}>;



test("sample server test", () => {
  const item: ShoppingListItemBase = { name: "TESTNAME", checked: false };
  ShoppingListItemModel.create(item);

  expect(true).toBeTruthy();
});
