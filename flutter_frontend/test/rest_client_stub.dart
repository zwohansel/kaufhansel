import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';

class User {
  final ShoppingListUserInfo _info;
  final String _password;

  ShoppingListUserInfo get info => _info;
  String get password => _password;

  User(this._info, this._password);
}

class RestClientStub implements RestClient {
  final List<User> _users = [];

  void addUser(User user) => _users.add(user);

  @override
  Future<BackendInfo> getBackendInfo() {
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListUserInfo> login(String userEmail, String password) async {
    return _users
        .firstWhere((element) => element.info.emailAddress == userEmail && element.password == password, orElse: null)
        ?.info;
  }

  @override
  Future<Optional<ShoppingListUserReference>> addUserToShoppingList(String shoppingListId, String userEmailAddress) {
    throw UnimplementedError();
  }

  @override
  Future<void> changeShoppingListName(String shoppingListId, String newName) {
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListUserReference> changeShoppingListPermissions(
      String shoppingListId, String affectedUserId, ShoppingListRole newRole) {
    throw UnimplementedError();
  }

  @override
  Future<RegistrationProcessType> checkInviteCode(String inviteCode) {
    throw UnimplementedError();
  }

  @override
  void close() {}

  @override
  Future<ShoppingListInfo> createShoppingList(String shoppingListName) {
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListItem> createShoppingListItem(String shoppingListId, String name, String category) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAccount(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteShoppingList(String shoppingListId) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteShoppingListItem(String shoppingListId, ShoppingListItem item) {
    throw UnimplementedError();
  }

  @override
  Future<List<ShoppingListItem>> fetchShoppingList(String shoppingListId) {
    throw UnimplementedError();
  }

  @override
  Future<String> generateInviteCode() {
    throw UnimplementedError();
  }

  @override
  Future<List<ShoppingListInfo>> getShoppingLists() {
    throw UnimplementedError();
  }

  @override
  Future<void> moveShoppingListItem(String shoppingListId, ShoppingListItem item, int targetIndex) {
    throw UnimplementedError();
  }

  @override
  Future<RegistrationResult> register(String userName, String password, String inviteCode, {String emailAddress}) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeAllCategories(String shoppingListId) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeAllItems(String shoppingListId) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeUserFromShoppingList(String shoppingListId, String userId) {
    throw UnimplementedError();
  }

  @override
  Future<void> requestPasswordReset(String emailAddress) {
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword(String emailAddress, String resetCode, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> sendInvite(String emailAddress, {String shoppingListId}) {
    throw UnimplementedError();
  }

  @override
  void setAuthenticationToken(String token) {}

  @override
  Future<void> uncheckAllItems(String shoppingListId) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateShoppingListItem(String shoppingListId, ShoppingListItem item) {
    throw UnimplementedError();
  }
}
