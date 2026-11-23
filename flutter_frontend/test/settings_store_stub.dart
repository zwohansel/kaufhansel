import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/settings/settings_store.dart';

class SettingsStoreStub implements SettingsStore {
  int? _confirmedMessageNumber;
  ShoppingListUserInfo? _userInfo;
  String? _refreshToken;
  ShoppingListInfo? _activeShoppingList;
  List<ShoppingListInfo>? _cachedInfos;
  final Map<String, List<ShoppingListItem>> _baselineItems = {};
  final Map<String, List<ShoppingListItem>> _localItems = {};
  final Map<String, Map<String, String>> _aliases = {};
  int _sequenceNumber = 0;

  int? get confirmedMessageNumber => _confirmedMessageNumber;

  @override
  Future<String?> getRefreshToken() async {
    return _refreshToken;
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    _refreshToken = refreshToken;
  }

  @override
  Future<void> removeRefreshToken() async {
    _refreshToken = null;
  }

  @override
  Future<void> confirmInfoMessage(int messageNumber) async {
    _confirmedMessageNumber = messageNumber;
    return;
  }

  @override
  Future<ShoppingListUserInfo?> getUserInfo() async {
    return _userInfo;
  }

  @override
  Future<bool> isInfoMessageConfirmed(int messageNumber) async {
    return false;
  }

  @override
  Future<void> removeUserInfo() async {
    _userInfo = null;
  }

  @override
  Future<void> saveUserInfo(ShoppingListUserInfo info) async {
    _userInfo = info;
  }

  @override
  Future<ShoppingListInfo?> getActiveShoppingList() async {
    return _activeShoppingList;
  }

  @override
  Future<void> removeActiveShoppingList() async {
    _activeShoppingList = null;
  }

  @override
  Future<void> saveActiveShoppingList(ShoppingListInfo shoppingListInfo) async {
    _activeShoppingList = shoppingListInfo;
  }

  @override
  Future<List<ShoppingListInfo>?> getCachedShoppingListInfos() async => _cachedInfos;

  @override
  Future<void> saveCachedShoppingListInfos(List<ShoppingListInfo> infos) async {
    _cachedInfos = List.of(infos);
  }

  @override
  Future<List<ShoppingListItem>?> getBaselineItems(String listId) async => _copyOrNull(_baselineItems[listId]);

  @override
  Future<void> saveBaselineItems(String listId, List<ShoppingListItem> items) async {
    _baselineItems[listId] = _copy(items);
  }

  @override
  Future<List<ShoppingListItem>?> getLocalItems(String listId) async => _copyOrNull(_localItems[listId]);

  @override
  Future<void> saveLocalItems(String listId, List<ShoppingListItem> items) async {
    _localItems[listId] = _copy(items);
  }

  /// The real store serialises the items, so the caller can never get hold of
  /// the stored objects. Copying keeps the stub from handing out references to
  /// live model objects, which would hide bugs.
  List<ShoppingListItem> _copy(List<ShoppingListItem> items) => items.map((item) => item.copy()).toList();

  List<ShoppingListItem>? _copyOrNull(List<ShoppingListItem>? items) => items == null ? null : _copy(items);

  @override
  Future<Map<String, String>> getItemIdAliases(String listId) async => Map.of(_aliases[listId] ?? {});

  @override
  Future<void> saveItemIdAliases(String listId, Map<String, String> aliases) async {
    _aliases[listId] = Map.of(aliases);
  }

  @override
  Future<void> removeItemIdAliases(String listId) async {
    _aliases.remove(listId);
  }

  @override
  Future<int> getAndIncrementOfflineSequenceNumber() async => _sequenceNumber++;

  @override
  Future<void> removeSnapshotsExcept(Iterable<String> listIds) async {
    final keep = listIds.toSet();
    _baselineItems.removeWhere((listId, _) => !keep.contains(listId));
    _localItems.removeWhere((listId, _) => !keep.contains(listId));
    _aliases.removeWhere((listId, _) => !keep.contains(listId));
  }

  @override
  Future<void> removeSnapshots(String listId) async {
    _baselineItems.remove(listId);
    _localItems.remove(listId);
    _aliases.remove(listId);
  }

  @override
  Future<void> removeAll() async {
    _userInfo = null;
    _refreshToken = null;
    _activeShoppingList = null;
    _cachedInfos = null;
    _baselineItems.clear();
    _localItems.clear();
    _aliases.clear();
  }
}
