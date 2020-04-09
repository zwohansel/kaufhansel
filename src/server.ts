import bodyParser from "body-parser";
import express from "express";
import { AddressInfo } from "net";
import { ShoppingListItem } from "./ShoppingListItem";

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
