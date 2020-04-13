import { ApolloServer, UserInputError } from "apollo-server";
import Database from "./database";
import typeDefs from "./schema.graphql";

(async () => {
  try {
    const database = await Database.create("mongodb://localhost:27017");

    process.on("SIGINT", () => {
      console.log("Close DB connection");
      database.close().finally(() => process.exit());
    });

    const server = new ApolloServer({
      typeDefs,
      resolvers: {
        Query: {
          shoppingListItems: () => database.getShoppingListItems()
        },
        Mutation: {
          createShoppingListItem: (_parent, { name }) => database.createShoppingListItem(name),
          changeShoppingListItemCheckedState: async (_parent, { state, id }) => {
            const item = await database.setShoppingListItemCheckedState(id, state);

            if (!item) {
              throw new UserInputError(`The item with ID ${id} is not present.`);
            }

            return item;
          },
          deleteShoppingListItem: (_parent, { id }) => database.deleteShoppingListItem(id),
          clearShoppingList: () => database.clearShoppingList()
        }
      }
    });

    server.listen().then(({ url }) => {
      console.log("Server ready 🚀 at: ", url);
    });
  } catch (err) {
    console.error("An error occured: ", err);
    process.exit();
  }
})();
