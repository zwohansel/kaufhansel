import { ApolloProvider } from "@apollo/react-hooks";
import ApolloClient from "apollo-boost";
import React, { useState } from "react";
import ReactDOM from "react-dom";
import "./index.css";
import ShoppingListBoard from "./ShoppingListBoard";
import { Switch, BrowserRouter, Route, Redirect, useHistory } from "react-router-dom";
import LoginComponent from "./LoginComponent";

const client = new ApolloClient({
  uri: "/graphql"
});

function ShoppingListApp() {
  const [loggedIn, setLoggedIn] = useState(false);
  const history = useHistory();

  return (
    <Switch>
      <Route path="/login">
        <LoginComponent
          onLoginSuccess={() => {
            setLoggedIn(true);
            history.replace("/");
          }}
        />
      </Route>
      <Route
        path="/"
        render={({ location }) => {
          if (loggedIn) {
            return <ShoppingListBoard />;
          } else {
            return <Redirect to={{ pathname: "/login", state: { from: location } }} />;
          }
        }}
      ></Route>
    </Switch>
  );
}

ReactDOM.render(
  <React.StrictMode>
    <ApolloProvider client={client}>
      <BrowserRouter>
        <ShoppingListApp />
      </BrowserRouter>
    </ApolloProvider>
  </React.StrictMode>,
  document.getElementById("root")
);
