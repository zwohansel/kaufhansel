export interface ShoppingListItemBase {
  name: string;
  checked: boolean;
}

export interface ShoppingListItem extends ShoppingListItemBase {
  _id?: string;
}
