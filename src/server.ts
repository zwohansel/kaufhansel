import bodyParser from "body-parser";
import express from "express";
import { AddressInfo } from "net";
import { ShoppingListItem } from "./ShoppingListItem";
import { CheckedStateRequest } from "./CheckedStateRequest";

const app = express();

app.use(bodyParser.json());

const data: ShoppingListItem[] = [];

let counter = 1;

app.get("/api/shoppingList", (req, res) => {
  res.send(data);
});

app.post("/api/shoppingListItem", (req, res) => {
  const item: ShoppingListItem = req.body;
  item.id = counter;
  counter++;
  data.push(item);
  res.status(201).send(item);
});

app.put("/api/shoppingListItem/:id/changeCheckedState", (req, res) => {
  const id: number = parseInt(req.params.id, 10);
  const stateRequest: CheckedStateRequest = req.body;

  if (typeof stateRequest.state !== "boolean") {
    res.sendStatus(400);
    return;
  }

  const item = data.find((e) => e.id === id);
  if (item) {
    item.checked = stateRequest.state === true;
    res.sendStatus(204);
  } else {
    res.sendStatus(404);
  }
});

var server = app.listen(8081, () => {
  const serverInfo = server.address() as AddressInfo;
  if (server !== null) {
    const host = serverInfo.address;
    const port = serverInfo.port;
    console.log("Example app listening at http://%s:%s", host, port);
  } else {
    console.log("Could not start server");
  }
});
