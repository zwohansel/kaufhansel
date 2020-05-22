import gql from "graphql-tag";
import { ShoppingListItem } from "./ShoppingListItem";

interface GraphQlResponse<T> {
  success: boolean;
  message: string;
  data?: T;
}

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

export interface ShoppingListItemsData {
  shoppingListItems: ShoppingListItem[];
}

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
  __typename?: string;
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

export const LOGIN = gql`
  mutation login($username: String!, $password: String!) {
    login(username: $username, password: $password) {
      success
      message
    }
  }
`;

export interface LoginData {
  login: GraphQlResponse<void>;
}

export interface LoginVariables {
  username: string;
  password: string;
}
