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
  final RegistrationResult Function(String userName, String password, {String emailAddress}) onRegister;
  final void Function(String emailAddress) onPasswordResetRequest;
  final void Function(String emailAddress, String resetCode, String password) onPasswordReset;

  final List<User> _users = [];
  final Map<String, RegistrationProcessType> _inviteCodes = {};
  ShoppingListItem _createdShoppingListItem;

  RestClientStub({this.onRegister, this.onPasswordResetRequest, this.onPasswordReset});

  void addUser(User user) => _users.add(user);

  void addInviteCode(String code, RegistrationProcessType type) {
    _inviteCodes[code] = type;
  }

  void mockCreateShoppingListItem(ShoppingListItem item) {
    _createdShoppingListItem = item;
  }

  ShoppingListItem updatedShoppingListItem;

  @override
  Future<BackendInfo> getBackendInfo() {
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListUserInfo> login(String userEmail, String password) async {
    for (final user in _users) {
      if (user.info.emailAddress == userEmail && user.password == password) {
        return user.info;
      }
    }
    return null;
  }

  @override
  Future<RegistrationProcessType> checkInviteCode(String inviteCode) async {
    return _inviteCodes[inviteCode] ?? RegistrationProcessType.INVALID;
  }

  @override
  Future<RegistrationResult> register(String userName, String password, String inviteCode,
      {String emailAddress}) async {
    if (onRegister == null) {
      return RegistrationResult(RegistrationResultStatus.FAILURE);
    }

    final type = await checkInviteCode(inviteCode);
    if (type == RegistrationProcessType.FULL_REGISTRATION && emailAddress != null && emailAddress.isNotEmpty) {
      return onRegister(userName, password, emailAddress: emailAddress);
    } else if (type == RegistrationProcessType.WITHOUT_EMAIL) {
      return onRegister(userName, password);
    }
    return RegistrationResult(RegistrationResultStatus.FAILURE);
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
  void close() {}

  @override
  Future<ShoppingListInfo> createShoppingList(String shoppingListName) {
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListItem> createShoppingListItem(String shoppingListId, String name, String category) async {
    return _createdShoppingListItem;
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
  Future<void> requestPasswordReset(String emailAddress) async {
    this?.onPasswordResetRequest(emailAddress);
  }

  @override
  Future<void> resetPassword(String emailAddress, String resetCode, String password) async {
    this?.onPasswordReset(emailAddress, resetCode, password);
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
  Future<void> updateShoppingListItem(String shoppingListId, ShoppingListItem item) async {
    updatedShoppingListItem = item;
  }
}
