import 'dart:developer';

import 'package:kaufhansel_client/model.dart';
import 'package:localstorage/localstorage.dart';

const _userInfoStorageKey = "userInfo";

class SettingsStore {
  final LocalStorage _storage = new LocalStorage('kaufhansel_settings');

  Future<Optional<ShoppingListUserInfo>> getUserInfo() async {
    if (!await _storage.ready) {
      return Optional.empty();
    }
    final userInfoJson = _storage.getItem(_userInfoStorageKey);
    if (userInfoJson == null) {
      return Optional.empty();
    }
    return Optional(ShoppingListUserInfo.fromJson(userInfoJson));
  }

  Future<void> saveUserInfo(ShoppingListUserInfo info) async {
    if (await _storage.ready) {
      await _storage.setItem(_userInfoStorageKey, info);
    } else {
      log("Could not save user info: Storage not writeable.");
    }
  }

  Future<void> removeUserInfo() async {
    if (!await _storage.ready) {
      throw Exception("Failed to remove user info: Storage not writeable");
    }
    await _storage.deleteItem(_userInfoStorageKey);
  }
}
