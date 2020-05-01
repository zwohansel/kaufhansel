import { ApolloProvider } from "@apollo/react-hooks";
import ApolloClient from "apollo-boost";
import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import ShoppingListBoard from "./ShoppingListBoard";

const client = new ApolloClient({
  uri: "/graphql"
});

ReactDOM.render(
  <React.StrictMode>
    <ApolloProvider client={client}>
      <ShoppingListBoard />
    </ApolloProvider>
  </React.StrictMode>,
  document.getElementById("root")
);
