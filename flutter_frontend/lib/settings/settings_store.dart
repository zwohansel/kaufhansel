import 'dart:convert';

import 'package:kaufhansel_client/model.dart';
import 'package:localstorage/localstorage.dart';

const _userInfoStorageKey = "userInfo";
const _infoMessageConfirmedStorageKey = "infoMessageConfirmed";
const _lastActiveShoppingListKey = "lastActiveShoppingListId";

class SettingsStore {
  Future<void> removeAll() async {
    localStorage.clear();
  }

  Future<ShoppingListUserInfo?> getUserInfo() async {
    final userInfoJson = localStorage.getItem(_userInfoStorageKey);
    if (userInfoJson == null) {
      return null;
    }
    return ShoppingListUserInfo.fromJson(jsonDecode(userInfoJson));
  }

  Future<void> saveUserInfo(ShoppingListUserInfo info) async {
    localStorage.setItem(_userInfoStorageKey, jsonEncode(info));
  }

  Future<void> removeUserInfo() async {
    localStorage.removeItem(_userInfoStorageKey);
  }

  Future<void> confirmInfoMessage(int messageNumber) async {
    localStorage.setItem(_infoMessageConfirmedStorageKey, messageNumber.toString());
  }

  Future<bool> isInfoMessageConfirmed(int messageNumber) async {
    final confirmedMessageNumberStr = localStorage.getItem(_infoMessageConfirmedStorageKey);
    if (confirmedMessageNumberStr == null) {
      return false;
    }
    final confirmedMessageNumber = int.tryParse(confirmedMessageNumberStr);
    if (confirmedMessageNumber == null) {
      return false;
    }
    return confirmedMessageNumber >= messageNumber;
  }

  Future<void> saveActiveShoppingList(ShoppingListInfo shoppingListInfo) async {
    localStorage.setItem(_lastActiveShoppingListKey, jsonEncode(shoppingListInfo));
  }

  Future<void> removeActiveShoppingList() async {
    localStorage.removeItem(_lastActiveShoppingListKey);
  }

  Future<ShoppingListInfo?> getActiveShoppingList() async {
    final lastActiveShoppingList = localStorage.getItem(_lastActiveShoppingListKey);
    if (lastActiveShoppingList == null) {
      return null;
    }
    return ShoppingListInfo.fromJson(jsonDecode(lastActiveShoppingList));
  }
}
