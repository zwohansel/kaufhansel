import 'package:flutter/foundation.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';

/// A shopping list that is synchronized with a remote backend
class SyncedShoppingList extends ChangeNotifier {
  final RestClient _client;
  final ShoppingList _list;

  SyncedShoppingList(this._client, this._list) {
    _list.addListener(_underlyingListChanged);
  }

  ShoppingListInfo get info => _list.info;

  void _underlyingListChanged() {
    notifyListeners();
  }

  List<SyncedShoppingListItem> get items {
    return List.unmodifiable(_list.items.map((item) => SyncedShoppingListItem(this, item)));
  }

  List<String> getAllCategories() {
    return _list.getAllCategories();
  }

  List<String> getUserCategories() {
    return _list.getUserCategories();
  }

  Future<void> uncheckItems({String? ofCategory}) async {
    await _client.uncheckItems(_list.id, ofCategory: ofCategory);
    _list.items
        .where((item) => ofCategory == null || item.category == ofCategory)
        .forEach((item) => item.checked = false);
  }

  Future<void> deleteCheckedItems({String? ofCategory}) async {
    await _client.deleteCheckedShoppingListItems(_list.id, ofCategory);
    _list.removeItemsWhere((item) => item.checked && (ofCategory == null || item.category == ofCategory));
  }

  Future<void> renameCategory(String oldCategoryName, String newCategoryName) async {
    await _client.renameCategory(_list.id, oldCategoryName, newCategoryName);
    _list.items.where((item) => item.category == oldCategoryName).forEach((item) => item.category = newCategoryName);
  }

  Future<void> removeCategory(String? category) async {
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

  Future<void> addNewItem(String name, String? category) async {
    // category CATEGORY_ALL is virtual, do not add it to items
    final actualCategory = category == CATEGORY_ALL ? null : category;
    final shoppingListItem = await _client.createShoppingListItem(_list.id, name, actualCategory);
    _list.addItem(shoppingListItem);
  }

  Future<void> moveItemsInSubList(
      List<SyncedShoppingListItem> subList, int oldIndexInSubList, int newIndexInSubList) async {
    final item = subList[oldIndexInSubList];
    final oldIndex = _list.items.indexOf(item._item);

    int newIndex;
    if (newIndexInSubList < subList.length) {
      newIndex = _list.items.indexOf(subList[newIndexInSubList]._item);
    } else {
      newIndex = _list.items.indexOf(subList.last._item) + 1;
    }

    // Perform the move even if the move request to the server fails.
    // Otherwise the item is first moved back to its original position
    // and then jumps to the new position once the request is finished.
    _list.moveItem(item._item, newIndex);
    try {
      await _client.moveShoppingListItem(_list.id, item._item, newIndex);
    } on HttpResponseException {
      // Undo the move if the request fails
      _list.moveItem(item._item, oldIndex);
      rethrow;
    }
  }

  void dispose() {
    _list.removeListener(_underlyingListChanged);
    _list.dispose();
    super.dispose();
  }
}

/// A shopping list that is synchronized with a remote backend
class SyncedShoppingListItem extends ChangeNotifier {
  final SyncedShoppingList _owner;
  final ShoppingListItem _item;

  SyncedShoppingListItem(this._owner, this._item) {
    _item.addListener(_underlyingItemChanged);
  }

  void _underlyingItemChanged() {
    notifyListeners();
  }

  String? get id => _item.id;

  bool get checked => _item.checked;
  Future<void> setChecked(bool value) async {
    // Checking and un-checking an item should be a fast and work under all circumstances (even if there is not internet connection)
    // Therefore we do not wait for the server reply and accept that the
    // checked state of an item may get out of sync with the state stored on the server.
    _item.checked = value;
    await _owner._client.updateShoppingListItem(_owner._list.id, _item);
  }

  bool hasUserCategory() => _item.hasUserCategory();

  bool isInCategory(String? category) => _item.isInCategory(category);

  String get name => _item.name;
  Future<void> setName(String name) async {
    if (name == _item.name) {
      return;
    }

    // apply the change to a copy of the actual item and send the copy to the server...
    final itemCopy = _item.copy();
    itemCopy.name = name;
    await _owner._client.updateShoppingListItem(_owner._list.id, itemCopy);
    // ...change the actual item once we know that the request was successful
    _item.name = name;
  }

  String? get category => _item.category;

  Future<void> setCategory(String? category) async {
    if (category == _item.category) {
      return;
    }

    // apply the change to a copy of the actual item and send the copy to the server...
    final itemCopy = _item.copy();
    itemCopy.category = category;
    await _owner._client.updateShoppingListItem(_owner._list.id, itemCopy);
    // ...change the actual item once we know that the request was successful
    _item.category = category;
  }

  /// Deletes the item by removing it from its list.
  /// Once deleted the object should be discarded.
  /// Getters will continue to work but all other methods will fail.
  Future<void> delete() async {
    await _owner._client.deleteShoppingListItem(_owner._list.id, _item);
    _owner._list.removeItem(_item);
  }

  @override
  void dispose() {
    _item.removeListener(_underlyingItemChanged);
    _item.dispose();
    super.dispose();
  }
}
