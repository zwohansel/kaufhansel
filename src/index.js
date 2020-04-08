import React, { Component } from "react";
import ReactDOM from "react-dom";

function HelloWorld() {
  return <h1>Hallo, Welt!</h1>;
}

const wrapper = document.getElementById("root");
wrapper ? ReactDOM.render(<HelloWorld/>, wrapper) : false;
