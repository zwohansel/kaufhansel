export interface ShoppingListItemBase {
  __typename?: string;
  name: string;
  checked: boolean;
  assignee: string;
}

export interface ShoppingListItem extends ShoppingListItemBase {
  _id: string;
}
