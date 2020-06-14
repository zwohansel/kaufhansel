import gql from "graphql-tag";
import { ShoppingListItem } from "./ShoppingListItem";

interface GraphQlResponse<T> {
  success: boolean;
  message: string;
  data?: T;
}

export const GET_ITEMS = gql`
  query shoppingListItems {
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

export const UPDATEM_ITEMS = gql`
  mutation updateItems($items: [ShoppingListItemInput!]!) {
    updateShoppingListItems(items: $items) {
      _id
      name
      checked
      assignee
    }
  }
`;

export interface UpdateItemData {
  __typename?: string;
  updateShoppingListItems: ShoppingListItem[];
}

export interface UpdateItemVariables {
  items: ShoppingListItem[];
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

export const SHOPPING_LIST_CHANGED = gql`
  subscription shoppingListChanged {
    shoppingListChanged {
      item {
        _id
        assignee
        checked
        name
      }
      type
    }
  }
`;

export interface ShoppingListChangedEvent {
  type: string;
  item: ShoppingListItem;
}

export interface ShoppingListChangedData {
  shoppingListChanged: ShoppingListChangedEvent[];
}
