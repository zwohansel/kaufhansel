import { ApolloProvider } from "@apollo/react-hooks";
import { InMemoryCache } from "apollo-cache-inmemory";
import ApolloClient from "apollo-client";
import { ApolloLink, split } from "apollo-link";
import { HttpLink } from "apollo-link-http";
import { RetryLink } from "apollo-link-retry";
import { WebSocketLink } from "apollo-link-ws";
import { getMainDefinition } from "apollo-utilities";
import React, { useState } from "react";
import ReactDOM from "react-dom";
import { BrowserRouter, Redirect, Route, Switch, useHistory } from "react-router-dom";
import "./index.css";
import LoginComponent from "./LoginComponent";
import ShoppingListBoard from "./ShoppingListBoard";
import { parseUserIdFromCookieString } from "./utils";

const websocketProtocol = window.location.protocol === "https:" ? "wss" : "ws";
const websocketUri = `${websocketProtocol}://${window.location.host}/graphql`;

const httpLink = new HttpLink({ uri: "/graphql" });

const wsLink = new WebSocketLink({
  uri: websocketUri,
  options: {
    reconnect: true
  }
});

const splitLink = split(
  ({ query }) => {
    const definition = getMainDefinition(query);
    return definition.kind === "OperationDefinition" && definition.operation === "subscription";
  },
  wsLink,
  httpLink
);

const client = new ApolloClient({
  cache: new InMemoryCache(),
  link: ApolloLink.from([
    new RetryLink({
      delay: {
        initial: 300,
        max: 5000,
        jitter: true
      },
      attempts: {
        max: Infinity,
        retryIf: (error, operation) => {
          return operation.operationName !== "shoppingListItems" && !!error;
        }
      }
    }),
    splitLink
  ])
});

function ShoppingListApp() {
  const [loggedIn, setLoggedIn] = useState(parseUserIdFromCookieString(document.cookie) !== "");
  const [userId, setUserId] = useState(parseUserIdFromCookieString(document.cookie));
  const history = useHistory();

  return (
    <Switch>
      <Route path="/login">
        <LoginComponent
          onLoginSuccess={userId => {
            setUserId(userId);
            setLoggedIn(true);
            history.replace("/");
          }}
        />
      </Route>
      <Route
        path="/"
        render={({ location }) => {
          if (loggedIn) {
            return <ShoppingListBoard onAuthenticationError={() => setLoggedIn(false)} userId={userId} />;
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
