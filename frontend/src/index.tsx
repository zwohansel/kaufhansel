import { ApolloProvider } from "@apollo/react-hooks";
import ApolloClient from "apollo-boost";
import React, { useState } from "react";
import ReactDOM from "react-dom";
import { BrowserRouter, Redirect, Route, Switch, useHistory } from "react-router-dom";
import "./index.css";
import LoginComponent from "./LoginComponent";
import ShoppingListBoard from "./ShoppingListBoard";

const client = new ApolloClient({
  uri: "/graphql"
});

function ShoppingListApp() {
  const [loggedIn, setLoggedIn] = useState(document.cookie.includes("SHOPPER_LOGGED_IN=true"));
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
            return <ShoppingListBoard onAuthenticationError={() => setLoggedIn(false)} />;
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
