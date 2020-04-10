import bodyParser from "body-parser";
import express from "express";
import { ObjectID } from "mongodb";
import mongoose from "mongoose";
import { AddressInfo } from "net";
import { CheckedStateRequest } from "./CheckedStateRequest";
import { ShoppingListItem, ShoppingListItemBase } from "./ShoppingListItem";

const ShoppintListItemSchema = new mongoose.Schema({
  name: String,
  checked: Boolean
});

interface ShoppingListItemDocument
  extends ShoppingListItemBase,
    mongoose.Document {}

const ShoppingListItemModel = mongoose.model<ShoppingListItemDocument>(
  "shopping_list_item",
  ShoppintListItemSchema
);

(async () => {
  try {
    const app = express();

    app.use(bodyParser.json());

    const mongooseDb = await mongoose.connect("mongodb://localhost:27017", {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      connectTimeoutMS: 5000,
      serverSelectionTimeoutMS: 5000,
      dbName: "shopping_list"
    });

    process.on("SIGINT", () => {
      console.log("Close DB connection");
      mongooseDb.disconnect().finally(() => process.exit());
    });

    mongooseDb.connection.on(
      "error",
      console.error.bind(console, "connection error")
    );

    app.get("/api/shoppingList", async (req, res) => {
      const shoppingListItems: ShoppingListItem[] = await ShoppingListItemModel.find().exec();
      res.send(shoppingListItems);
    });

    app.post("/api/shoppingListItem", async (req, res) => {
      const item: ShoppingListItem = req.body;
      const insertedItem = await ShoppingListItemModel.create(item);
      res.status(201).send(insertedItem);
    });

    app.put(
      "/api/shoppingListItem/:id/changeCheckedState",
      async (req, res) => {
        const itemId: ObjectID = ObjectID.createFromHexString(req.params.id);
        const stateRequest: CheckedStateRequest = req.body;

        if (typeof stateRequest.state !== "boolean") {
          res.sendStatus(400);
          return;
        }

        const item = await ShoppingListItemModel.updateOne(
          { _id: itemId },
          { checked: stateRequest.state === true }
        );

        if (item) {
          res.sendStatus(204);
        } else {
          res.sendStatus(404);
        }
      }
    );

    const server = app.listen(8081, () => {
      const serverInfo = server.address() as AddressInfo;
      if (server !== null) {
        const host = serverInfo.address;
        const port = serverInfo.port;
        console.log("Example app listening at http://%s:%s", host, port);
      } else {
        console.log("Could not start server");
      }
    });
  } catch (err) {
    console.error("An error occured: ", err);
    process.exit();
  }
})();
