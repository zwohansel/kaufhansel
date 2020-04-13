import { ApolloServer, UserInputError } from "apollo-server";
import Database from "./Database";
import typeDefs from "./schema.graphql";

(async () => {
  try {
    console.log("Connecting to database...");
    const database = await Database.create("mongodb://localhost:27017");

    process.on("SIGINT", async () => {
      console.log("\nClosing DB connection...");
      try {
        await database.close();
      } finally {
        console.log("Shutting down...");
        process.exit();
      }
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

    const serverInfo = await server.listen();
    console.log(`
🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀
            Server ready at: ${serverInfo.url}
🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀`);
  } catch (err) {
    console.error("An error occured: ", err);
    process.exit();
  }
})();
