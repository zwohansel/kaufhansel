import { gql } from "apollo-boost";
import { ShoppingListItem } from "../shared/ShoppingListItem";

export const GET_ITEMS = gql`
  {
    shoppingListItems {
      _id
      name
      checked
      assignee
    }
  }
`;

export const CREATE_ITEM = gql`
  mutation createShoppingListItem($name: String!) {
    createShoppingListItem(name: $name) {
      _id
      name
      checked
      assignee
    }
  }
`;

export interface CreateShoppingListItemData {
  createShoppingListItem: ShoppingListItem;
}

export const DELETE_ITEM = gql`
  mutation deleteItem($id: ID!) {
    deleteShoppingListItem(id: $id)
  }
`;

export interface DeleteShoppingListItemData {
  deleteShoppingListItem: string;
}

export const UPDATEM_ITEM = gql`
  mutation updateItem($id: ID!, $state: Boolean, $assignee: String) {
    updateShoppingListItem(id: $id, state: $state, assignee: $assignee) {
      _id
      name
      checked
      assignee
    }
  }
`;

export interface UpdateItemData {
  updateShoppingListItem: ShoppingListItem;
}

export interface UpdateItemVariables {
  id: string;
  state?: boolean;
  assignee?: string;
}

export const CLEAR_LIST = gql`
  mutation clearList {
    clearShoppingList
  }
`;

export interface ClearShoppingListData {
  clearShoppingList: boolean;
}

export interface ShoppingListItemsData {
  shoppingListItems: ShoppingListItem[];
}
