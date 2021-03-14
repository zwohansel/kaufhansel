import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/settings/settings_store.dart';

class SettingsStoreStub implements SettingsStore {
  int _confirmedMessageNumber;
  ShoppingListUserInfo _userInfo;

  int get confirmedMessageNumber => _confirmedMessageNumber;

  @override
  Future<void> confirmInfoMessage(int messageNumber) async {
    _confirmedMessageNumber = messageNumber;
    return;
  }

  @override
  Future<Optional<ShoppingListUserInfo>> getUserInfo() async {
    return Optional(_userInfo);
  }

  @override
  Future<bool> isInfoMessageConfirmed(int messageNumber) async {
    return false;
  }

  @override
  Future<void> removeUserInfo() async {}

  @override
  Future<void> saveUserInfo(ShoppingListUserInfo info) async {
    _userInfo = info;
  }
}
