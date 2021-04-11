import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';

/// A shopping list that is synchronized with a remote backend
class SyncedShoppingList {
  final RestClient _client;
  final ShoppingList _list;

  SyncedShoppingList(this._client, this._list);

  // TODO: When SyncedShoppingList is complete it should no longer be necessary to expose the underlying list
  ShoppingList get list => _list;

  Future<void> uncheckItems({String ofCategory}) async {
    await _client.uncheckItems(_list.id, ofCategory: ofCategory);
    _list.items
        .where((item) => ofCategory == null || item.category == ofCategory)
        .forEach((item) => item.checked = false);
  }

  Future<void> deleteCheckedItems({String ofCategory}) async {
    await _client.deleteShoppingListItems(_list.id, ofCategory);
    _list.removeItemsWhere((item) => item.checked && (ofCategory == null || item.category == ofCategory));
  }

  Future<void> renameCategory(String oldCategoryName, String newCategoryName) async {
    await _client.renameCategory(_list.id, oldCategoryName, newCategoryName);
    _list.items.where((item) => item.category == oldCategoryName).forEach((item) => item.category = newCategoryName);
  }

  Future<void> removeCategory(String category) async {
    await _client.removeCategory(_list.id, category: category);
    _list.items.where((item) => item.category == category).forEach((item) => item.category = null);
  }

  Future<void> removeAllCategories() async {
    await _client.removeCategory(_list.id);
    _list.items.forEach((item) => item.category = null);
  }

  Future<void> removeAllItems() async {
    await _client.removeAllItems(_list.id);
    _list.removeAllItems();
  }

  void dispose() {
    this._list.dispose();
  }
}
