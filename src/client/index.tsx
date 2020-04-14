import { ApolloProvider } from "@apollo/react-hooks";
import ApolloClient from "apollo-boost";
import React from "react";
import ReactDOM from "react-dom";
import ShoppingListComponent from "./ShoppingListComponent";
import "./index.css";

const client = new ApolloClient({
  uri: "http://localhost:4000"
});

ReactDOM.render(
  <React.StrictMode>
    <ApolloProvider client={client}>
      <ShoppingListComponent />
    </ApolloProvider>
  </React.StrictMode>,
  document.getElementById("root")
);
