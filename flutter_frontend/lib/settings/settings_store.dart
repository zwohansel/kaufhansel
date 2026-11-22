import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:localstorage/localstorage.dart';

const _userInfoStorageKey = "userInfo";
const _infoMessageConfirmedStorageKey = "infoMessageConfirmed";
const _lastActiveShoppingListKey = "lastActiveShoppingListId";
const _refreshTokenStorageKey = "refreshToken";

class SettingsStore {
  /// Stores values that must not be readable by anyone but this app
  /// (Android Keystore, iOS/macOS Keychain, libsecret on Linux).
  final _secureStorage = const FlutterSecureStorage();

  Future<void> removeAll() async {
    localStorage.clear();
    await _secureStorage.deleteAll();
  }

  /// The refresh token is required to obtain a new authentication token
  /// once the current one has expired.
  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenStorageKey, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenStorageKey);
  }

  Future<void> removeRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenStorageKey);
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
