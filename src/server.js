var express = require("express");
var app = express();

app.get("/", function (req, res) {
  res.send("Up");
});

app.get("/shoppingList", function (req, res) {
  const data = [
    { name: "Kaffee", checked: false },
    { name: "Skyr", checked: true },
  ];
  res.send(data);
});

var server = app.listen(8081, function () {
  var host = server.address().address;
  var port = server.address().port;

  console.log("Example app listening at http://%s:%s", host, port);
});
