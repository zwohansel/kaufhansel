import 'dart:developer';

import 'package:kaufhansel_client/model.dart';
import 'package:localstorage/localstorage.dart';

const _userInfoStorageKey = "userInfo";
const _infoMessageConfirmedStorageKey = "infoMessageConfirmed";
const _lastActiveShoppingListKey = "lastActiveShoppingListId";

class SettingsStore {
  final LocalStorage _storage = new LocalStorage('kaufhansel_settings');

  Future<void> removeAll() async {
    _storage.clear();
  }

  Future<ShoppingListUserInfo?> getUserInfo() async {
    if (!await _storage.ready) {
      return null;
    }
    final userInfoJson = _storage.getItem(_userInfoStorageKey);
    if (userInfoJson == null) {
      return null;
    }
    return ShoppingListUserInfo.fromJson(userInfoJson);
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

  Future<void> confirmInfoMessage(int messageNumber) async {
    if (await _storage.ready) {
      await _storage.setItem(_infoMessageConfirmedStorageKey, messageNumber);
    } else {
      log("Could not confirm info message: Storage not writeable.");
    }
  }

  Future<bool> isInfoMessageConfirmed(int messageNumber) async {
    if (!await _storage.ready) {
      return false;
    }
    final confirmedMessageNumber = _storage.getItem(_infoMessageConfirmedStorageKey);
    if (confirmedMessageNumber == null) {
      return false;
    }
    return confirmedMessageNumber >= messageNumber;
  }

  Future<void> saveActiveShoppingList(ShoppingListInfo shoppingListInfo) async {
    if (await _storage.ready) {
      await _storage.setItem(_lastActiveShoppingListKey, shoppingListInfo);
    } else {
      log("Could not save active shopping list id: Storage not writeable.");
    }
  }

  Future<void> removeActiveShoppingList() async {
    if (!await _storage.ready) {
      throw Exception("Failed to remove active shopping list info: Storage not writeable");
    }
    await _storage.deleteItem(_lastActiveShoppingListKey);
  }

  Future<ShoppingListInfo?> getActiveShoppingList() async {
    if (!await _storage.ready) {
      return null;
    }
    final lastActiveShoppingList = _storage.getItem(_lastActiveShoppingListKey);
    if (lastActiveShoppingList == null) {
      return null;
    }
    return ShoppingListInfo.fromJson(lastActiveShoppingList);
  }
}
