import 'package:kaufhansel_client/model.dart';

/// An in-memory stand-in for the backend's item storage.
///
/// Needed wherever a test has to change the server state behind the client's
/// back, which is the only way to exercise the conflict handling. Ids are
/// handed out exactly like the real backend does: numeric and server side.
class FakeBackend {
  final Map<String, List<ShoppingListItem>> _lists = {};
  int _nextId;

  FakeBackend({int firstId = 1}) : _nextId = firstId;

  /// Replaces the stored items of the list. Takes copies, so the test keeps no
  /// references into the server state.
  void setItems(String listId, List<ShoppingListItem> items) {
    _lists[listId] = items.map((item) => item.copy()).toList();
    // Keep the id sequence ahead of the seeded items, exactly like a database
    // sequence would be. Handing out an id twice would make deletes hit two
    // items at once.
    for (final item in items) {
      final id = int.tryParse(item.id ?? "");
      if (id != null && id >= _nextId) {
        _nextId = id + 1;
      }
    }
  }

  /// The stored items, as copies: a client must never be able to change the
  /// server state by mutating what it read.
  List<ShoppingListItem> fetch(String listId) {
    final items = _lists[listId];
    if (items == null) {
      throw StateError("No list $listId");
    }
    return items.map((item) => item.copy()).toList();
  }

  List<ShoppingListItem> _itemsOf(String listId) {
    final items = _lists[listId];
    if (items == null) {
      throw StateError("No list $listId");
    }
    return items;
  }

  ShoppingListItem? _find(String listId, String? id) {
    return _itemsOf(listId).where((item) => item.id == id).firstOrNull;
  }

  ShoppingListItem create(String listId, String name, String? category) {
    final created = ShoppingListItem((_nextId++).toString(), name, false, category);
    _itemsOf(listId).add(created);
    return created.copy();
  }

  void update(String listId, ShoppingListItem item) {
    final stored = _find(listId, item.id);
    if (stored == null) {
      throw StateError("No item ${item.id} in list $listId");
    }
    stored.name = item.name;
    stored.checked = item.checked;
    stored.category = item.category;
  }

  void delete(String listId, ShoppingListItem item) {
    _itemsOf(listId).removeWhere((stored) => stored.id == item.id);
  }

  void move(String listId, ShoppingListItem item, int targetIndex) {
    final items = _itemsOf(listId);
    final current = items.indexWhere((stored) => stored.id == item.id);
    if (current < 0) {
      throw StateError("No item ${item.id} in list $listId");
    }
    final stored = items.removeAt(current);
    items.insert(targetIndex > items.length ? items.length : targetIndex, stored);
  }

  void uncheckItems(String listId, String? category) {
    _itemsOf(listId)
        .where((item) => category == null || item.category == category)
        .forEach((item) => item.checked = false);
  }

  void renameCategory(String listId, String oldCategory, String newCategory) {
    _itemsOf(listId).where((item) => item.category == oldCategory).forEach((item) => item.category = newCategory);
  }

  void removeCategory(String listId, String? category) {
    _itemsOf(listId)
        .where((item) => category == null || item.category == category)
        .forEach((item) => item.category = null);
  }

  void clear(String listId) {
    _itemsOf(listId).clear();
  }
}
