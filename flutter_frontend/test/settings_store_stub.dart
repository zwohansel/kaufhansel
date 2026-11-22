import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/settings/settings_store.dart';

class SettingsStoreStub implements SettingsStore {
  int? _confirmedMessageNumber;
  ShoppingListUserInfo? _userInfo;
  String? _refreshToken;

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
    return null;
  }

  @override
  Future<void> removeActiveShoppingList() async {
  }

  @override
  Future<void> saveActiveShoppingList(ShoppingListInfo shoppingListInfo) async {
  }

  @override
  Future<void> removeAll() async {
    _userInfo = null;
    _refreshToken = null;
  }
}
