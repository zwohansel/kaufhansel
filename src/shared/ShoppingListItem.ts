export interface ShoppingListItemBase {
  name: string;
  checked: boolean;
  assignee: string;
}

export interface ShoppingListItem extends ShoppingListItemBase {
  _id: string;
}
