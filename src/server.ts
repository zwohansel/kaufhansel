import bodyParser from "body-parser";
import express from "express";
import { AddressInfo } from "net";
import { CheckedStateRequest } from "./CheckedStateRequest";
import { ShoppingListItem } from "./ShoppingListItem";
import { MongoClient, ObjectID } from "mongodb";

(async () => {
  const app = express();

  app.use(bodyParser.json());

  const client = await MongoClient.connect("mongodb://localhost:27017");

  process.on("SIGINT", () => {
    console.log("Close DB connection");
    client.close();
    process.exit();
  });

  const db = client.db("shopping_list");
  const collection = db.collection("shopping_list_item");

  app.get("/api/shoppingList", async (req, res) => {
    const shoppingListItems: ShoppingListItem[] = await collection
      .find()
      .toArray();
    res.send(shoppingListItems);
  });

  app.post("/api/shoppingListItem", async (req, res) => {
    const item: ShoppingListItem = req.body;
    const result = await collection.insertOne(item);
    item._id = result.insertedId;
    res.status(201).send(item);
  });

  app.put("/api/shoppingListItem/:id/changeCheckedState", async (req, res) => {
    const itemId: ObjectID = ObjectID.createFromHexString(req.params.id);
    const stateRequest: CheckedStateRequest = req.body;

    if (typeof stateRequest.state !== "boolean") {
      res.sendStatus(400);
      return;
    }

    const item = await collection.findOneAndUpdate(
      { _id: itemId },
      { $set: { checked: stateRequest.state === true } }
    );

    if (item) {
      res.sendStatus(204);
    } else {
      res.sendStatus(404);
    }
  });

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
})();
