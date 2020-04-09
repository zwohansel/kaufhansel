import express from "express";
import { AddressInfo } from "net";

const app = express();

app.get("/shoppingList", function (req, res) {
  const data = [
    { name: "Kaffee", checked: false },
    { name: "Skyr", checked: true },
  ];
  res.send(data);
});

var server = app.listen(8081, function () {
  const serverInfo = server.address() as AddressInfo;
  if (server !== null) {
    const host = serverInfo.address;
    const port = serverInfo.port;
    console.log("Example app listening at http://%s:%s", host, port);
  } else {
    console.log("Could not start server");
  }
});
