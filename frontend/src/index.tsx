import { ApolloProvider } from "@apollo/react-hooks";
import { InMemoryCache } from "apollo-cache-inmemory";
import ApolloClient from "apollo-client";
import { ApolloLink, split } from "apollo-link";
import { onError } from "apollo-link-error";
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

const httpLink = new HttpLink({ uri: "/graphql" });

const wsLink = new WebSocketLink({
  uri: "ws://localhost:8080/graphql",
  options: {
    reconnect: false
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
        retryIf: error => !!error
      }
    }),
    onError(({ graphQLErrors, networkError }) => {
      console.log(graphQLErrors, networkError);
    }),
    splitLink
  ])
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
