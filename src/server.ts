import { ApolloServer, UserInputError } from "apollo-server";
import { ObjectID } from "mongodb";
import mongoose from "mongoose";
import typeDefs from "./schema.graphql";
import { ShoppingListItem, ShoppingListItemBase } from "./ShoppingListItem";

const ShoppintListItemSchema = new mongoose.Schema({
  name: String,
  checked: Boolean
});

interface ShoppingListItemDocument
  extends ShoppingListItemBase,
    mongoose.Document {}

const ShoppingListItemModel = mongoose.model<ShoppingListItemDocument>(
  "shopping_list_item",
  ShoppintListItemSchema
);

(async () => {
  try {
    const mongooseDb = await mongoose.connect("mongodb://localhost:27017", {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      connectTimeoutMS: 5000,
      serverSelectionTimeoutMS: 5000,
      dbName: "shopping_list"
    });

    process.on("SIGINT", () => {
      console.log("Close DB connection");
      mongooseDb.disconnect().finally(() => process.exit());
    });

    mongooseDb.connection.on(
      "error",
      console.error.bind(console, "connection error")
    );

    const server = new ApolloServer({
      typeDefs,
      resolvers: {
        Query: {
          shoppingListItems: async () => {
            const shoppingListItems: ShoppingListItem[] = await ShoppingListItemModel.find().exec();
            return shoppingListItems;
          }
        },
        Mutation: {
          createShoppingListItem: async (_parent, { name }) => {
            const item: ShoppingListItemBase = { name: name, checked: false };
            const insertedItem = await ShoppingListItemModel.create(item);
            return insertedItem;
          },
          changeShoppingListItemCheckedState: async (
            _parent,
            { state, id }
          ) => {
            const itemId: ObjectID = ObjectID.createFromHexString(id);
            const item = await ShoppingListItemModel.findOneAndUpdate(
              { _id: itemId },
              { checked: state },
              { new: true }
            );

            if (!item) {
              throw new UserInputError(
                `The item with ID ${id} is not present.`
              );
            }

            return item;
          },
          deleteShoppingListItem: async (_parent, { id }) => {
            await ShoppingListItemModel.findByIdAndDelete(id);
            return id;
          }
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
