import { ObjectID } from "mongodb";
import mongoose, { Model, Mongoose } from "mongoose";
import {
  ShoppingListItem,
  ShoppingListItemBase
} from "../shared/ShoppingListItem";

const ShoppintListItemSchema = new mongoose.Schema({
  name: String,
  checked: Boolean
});

interface ShoppingListItemDocument
  extends ShoppingListItemBase,
    mongoose.Document {}

export default class Database {
  private model: Model<ShoppingListItemDocument>;

  public static async create(mongoDbAddress: string): Promise<Database> {
    const database = await mongoose.connect(mongoDbAddress, {
      useUnifiedTopology: true,
      connectTimeoutMS: 5000,
      serverSelectionTimeoutMS: 5000,
      dbName: "shopping_list"
    });

    database.connection.on(
      "error",
      console.error.bind(console, "connection error")
    );

    return new Database(database);
  }

  private constructor(private database: Mongoose) {
    this.model = database.model<ShoppingListItemDocument>(
      "shopping_list_item",
      ShoppintListItemSchema
    );
  }

  public getShoppingListItems(): Promise<ShoppingListItem[]> {
    return this.model.find().exec();
  }

  public createShoppingListItem(name: string): Promise<ShoppingListItem> {
    const item: ShoppingListItemBase = { name: name, checked: false };
    return this.model.create(item);
  }

  public async setShoppingListItemCheckedState(
    id: string,
    state: boolean
  ): Promise<ShoppingListItem | null> {
    const itemId: ObjectID = ObjectID.createFromHexString(id);
    return await this.model.findOneAndUpdate(
      { _id: itemId },
      { checked: state },
      { new: true }
    );
  }

  public async deleteShoppingListItem(id: string): Promise<string> {
    await this.model.findByIdAndDelete(id);
    return id;
  }

  public async clearShoppingList(): Promise<void> {
    await this.model.collection.drop();
  }

  public close(): Promise<void> {
    return this.database.disconnect();
  }
}
