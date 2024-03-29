import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/login/login_page.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/utils/semantic_versioning.dart';
import 'package:kaufhansel_client/utils/update_check.dart';

import 'rest_client_stub.dart';
import 'settings_store_stub.dart';
import 'utils.dart';

void main() {
  const testLocale = Locale("de");
  late AppLocalizations localizations;

  setUp(() async {
    localizations = await AppLocalizations.load(testLocale);
  });

  testWidgets('SuccessfulLogin', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();

    // Create a registered user
    final user = new User(new ShoppingListUserInfo("12345", "TestUser", "test@test.de", "token"), "testpassword");
    client.addUser(user);

    ShoppingListUserInfo? loggedInUserInfo;
    final LoginPage loginPage = new LoginPage(loggedIn: (info) => loggedInUserInfo = info, update: Update.none());

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    // Enter email and password
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.emailHint, text: user.info.emailAddress);
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordHint, text: user.password);

    // Press login button
    await tester.tap(find.widgetWithText(ElevatedButton, localizations.buttonLogin));
    await tester.pumpAndSettle();

    // Login callback should have been called with the expected user info
    expect(loggedInUserInfo, equals(user.info));
  });

  testWidgets('InvalidLoginInformation', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();

    // Do not create a user -> any login will fail

    ShoppingListUserInfo? loggedInUserInfo;
    final LoginPage loginPage = new LoginPage(loggedIn: (info) => loggedInUserInfo = info, update: Update.none());

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    // Enter email and password
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.emailHint, text: "test@test.de");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordHint, text: "12345678");

    // Press login button
    await tester.tap(find.widgetWithText(ElevatedButton, localizations.buttonLogin));
    await tester.pumpAndSettle();

    // Login callback should not have been called
    expect(loggedInUserInfo, isNull);

    expect(find.text(localizations.exceptionWrongCredentials), findsOneWidget);
  });

  testWidgets('registration', (WidgetTester tester) async {
    final expectedEmail = "new@user.de";
    final expectedUser = "NewUser";
    final expectedPassword = "12345678";

    String? actualUserName;
    String? actualPassword;
    String? actualEmail;
    final RestClientStub client = new RestClientStub(onRegister: (userName, password, {emailAddress}) {
      actualUserName = userName;
      actualPassword = password;
      actualEmail = emailAddress;
      return RegistrationResult(RegistrationResultStatus.SUCCESS);
    });

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: Update.none());

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    // Press register button
    await tester.tap(find.widgetWithText(OutlinedButton, localizations.buttonRegister));
    await tester.pumpAndSettle();

    // Enter email, user name, password and password confirmation
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.emailHint, text: expectedEmail);
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.userNameHint, text: expectedUser);
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordHint, text: expectedPassword);
    await enterTextIntoFormField(tester,
        fieldLabelOrHint: localizations.passwordConfirmationHint, text: expectedPassword);

    // Check consent checkbox
    await tester.tap(find.byType(Checkbox));

    // Press register button
    final registerBtn = find.widgetWithText(ElevatedButton, localizations.buttonRegister);
    await tester.ensureVisible(registerBtn);
    await tester.tap(registerBtn);
    await tester.pumpAndSettle();

    // Check that onRegister was called with the expected information
    expect(actualEmail, equals(expectedEmail));
    expect(actualUserName, equals(expectedUser));
    expect(actualPassword, equals(expectedPassword));

    // Check that the activation email notice is shown for the expected email
    expect(find.text(localizations.activationLinkSent(expectedEmail)), findsOneWidget);
  });

  testWidgets('registrationWithAlreadyUsedEMail', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub(onRegister: (userName, password, {emailAddress}) {
      return RegistrationResult(RegistrationResultStatus.EMAIL_INVALID);
    });

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: Update.none());

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    // Press register button
    await tester.tap(find.widgetWithText(OutlinedButton, localizations.buttonRegister));
    await tester.pumpAndSettle();

    // Enter email, user name, password and password confirmation
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.emailHint, text: "test@test.de");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.userNameHint, text: "Test");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordHint, text: "12345678");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordConfirmationHint, text: "12345678");

    // Check consent checkbox
    await tester.tap(find.byType(Checkbox));

    // Press register button
    final registerBtn = find.widgetWithText(ElevatedButton, localizations.buttonRegister);
    await tester.ensureVisible(registerBtn);
    await tester.tap(registerBtn);
    await tester.pumpAndSettle();

    expect(find.text(localizations.emailAlreadyInUse), findsOneWidget);
  });

  testWidgets('registrationFailure', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub(onRegister: (userName, password, {emailAddress}) {
      return RegistrationResult(RegistrationResultStatus.FAILURE);
    });

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: Update.none());

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    // Press register button
    await tester.tap(find.widgetWithText(OutlinedButton, localizations.buttonRegister));
    await tester.pumpAndSettle();

    // Enter email, user name, password and password confirmation
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.emailHint, text: "test@test.de");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.userNameHint, text: "Test");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordHint, text: "12345678");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordConfirmationHint, text: "12345678");

    // Check consent checkbox
    await tester.tap(find.byType(Checkbox));

    // Press register button
    final registerBtn = find.widgetWithText(ElevatedButton, localizations.buttonRegister);
    await tester.ensureVisible(registerBtn);
    await tester.tap(registerBtn);
    await tester.pumpAndSettle();

    expect(find.text(localizations.exceptionRegistrationFailedTryAgainLater), findsOneWidget);
  });

  testWidgets('registrationWithInvalidEMail', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub(onRegister: (userName, password, {emailAddress}) {
      return RegistrationResult(RegistrationResultStatus.SUCCESS);
    });

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: Update.none());

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    // Press register button
    await tester.tap(find.widgetWithText(OutlinedButton, localizations.buttonRegister));
    await tester.pumpAndSettle();

    // Enter email, user name, password and password confirmation
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.emailHint, text: "");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.userNameHint, text: "Test");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordHint, text: "12345678");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordConfirmationHint, text: "12345678");

    // Check consent checkbox
    await tester.tap(find.byType(Checkbox));

    // Press register button
    final registerBtn = find.widgetWithText(ElevatedButton, localizations.buttonRegister);
    await tester.ensureVisible(registerBtn);
    await tester.tap(registerBtn);
    await tester.pumpAndSettle();

    expect(find.text(localizations.emailInvalid), findsOneWidget);
  });

  testWidgets('registrationWithInvalidUserName', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub(onRegister: (userName, password, {emailAddress}) {
      return RegistrationResult(RegistrationResultStatus.SUCCESS);
    });

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: Update.none());

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    // Press register button
    await tester.tap(find.widgetWithText(OutlinedButton, localizations.buttonRegister));
    await tester.pumpAndSettle();

    // Enter email, user name, password and password confirmation
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.emailHint, text: "test@test.de");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.userNameHint, text: "");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordHint, text: "12345678");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordConfirmationHint, text: "12345678");

    // Check consent checkbox
    await tester.tap(find.byType(Checkbox));

    // Press register button
    final registerBtn = find.widgetWithText(ElevatedButton, localizations.buttonRegister);
    await tester.ensureVisible(registerBtn);
    await tester.tap(registerBtn);
    await tester.pumpAndSettle();

    expect(find.text(localizations.userNameInvalid), findsOneWidget);
  });

  testWidgets('registrationWithInvalidPassword', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub(onRegister: (userName, password, {emailAddress}) {
      return RegistrationResult(RegistrationResultStatus.PASSWORD_INVALID);
    });

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: Update.none());

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    // Press register button
    await tester.tap(find.widgetWithText(OutlinedButton, localizations.buttonRegister));
    await tester.pumpAndSettle();

    // Enter email, user name, password and password confirmation
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.emailHint, text: "test@test.de");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.userNameHint, text: "Test");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordHint, text: "12345678");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordConfirmationHint, text: "12345678");

    // Check consent checkbox
    await tester.tap(find.byType(Checkbox));

    // Press register button
    final registerBtn = find.widgetWithText(ElevatedButton, localizations.buttonRegister);
    await tester.ensureVisible(registerBtn);
    await tester.tap(registerBtn);
    await tester.pumpAndSettle();

    expect(find.text(localizations.passwordInvalid), findsOneWidget);
  });

  testWidgets('registrationWithInvalidConfirmationPassword', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub(onRegister: (userName, password, {emailAddress}) {
      return RegistrationResult(RegistrationResultStatus.SUCCESS);
    });

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: Update.none());

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    // Press register button
    await tester.tap(find.widgetWithText(OutlinedButton, localizations.buttonRegister));
    await tester.pumpAndSettle();

    // Enter email, user name, password and password confirmation
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.emailHint, text: "test@test.de");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.userNameHint, text: "Test");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordHint, text: "12345678");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordConfirmationHint, text: "123456789");

    // Check consent checkbox
    await tester.tap(find.byType(Checkbox));

    // Press register button
    final registerBtn = find.widgetWithText(ElevatedButton, localizations.buttonRegister);
    await tester.ensureVisible(registerBtn);
    await tester.tap(registerBtn);
    await tester.pumpAndSettle();

    expect(find.text(localizations.passwordConfirmationInvalid), findsOneWidget);
  });

  testWidgets('registrationWithTooShortPassword', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub(onRegister: (userName, password, {emailAddress}) {
      return RegistrationResult(RegistrationResultStatus.SUCCESS);
    });

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: Update.none());

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    // Press register button
    await tester.tap(find.widgetWithText(OutlinedButton, localizations.buttonRegister));
    await tester.pumpAndSettle();

    // Enter email, user name, password and password confirmation
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.emailHint, text: "test@test.de");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.userNameHint, text: "Test");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordHint, text: "1234567");
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordConfirmationHint, text: "1234567");

    // Check consent checkbox
    await tester.tap(find.byType(Checkbox));

    // Press register button
    final registerBtn = find.widgetWithText(ElevatedButton, localizations.buttonRegister);
    await tester.ensureVisible(registerBtn);
    await tester.tap(registerBtn);
    await tester.pumpAndSettle();

    expect(find.text(localizations.passwordToShort), findsOneWidget);
  });

  testWidgets('resetPassword', (WidgetTester tester) async {
    final expectedEmail = "forgetfull@user.de";
    final expectedResetCode = "R3S3T";
    final expectedPassword = "newpassword";

    bool resetCodeRequested = false;
    String? newPassword;
    final RestClientStub client = new RestClientStub(
      onPasswordResetRequest: (emailAddress) {
        resetCodeRequested = expectedEmail == emailAddress;
      },
      onPasswordReset: (emailAddress, resetCode, password) {
        if (emailAddress == expectedEmail && resetCode == expectedResetCode) {
          newPassword = password;
        }
      },
    );

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: Update.none());

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    // Press "password forgotten" button
    var passwordForgottenBtn = find.widgetWithText(OutlinedButton, localizations.buttonPasswordForgotten);
    await tester.ensureVisible(passwordForgottenBtn);
    await tester.tap(passwordForgottenBtn);
    await tester.pumpAndSettle();

    // Enter email address
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.emailHint, text: expectedEmail);

    // Press "reset password" button
    await tester.tap(find.widgetWithText(ElevatedButton, localizations.buttonPasswordReset));
    await tester.pumpAndSettle();

    // Check that onPasswordResetRequest was called and the reset info text is shown
    expect(resetCodeRequested, isTrue);
    expect(find.text(localizations.passwordResetInfo), findsOneWidget);

    // Tapping the reset button should automatically open the password reset page
    // -> enter email address, reset code, and the new password + password confirmation
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.emailHint, text: expectedEmail);
    await enterTextIntoFormField(tester,
        fieldLabelOrHint: localizations.passwordResetCodeHint, text: expectedResetCode);
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordNewHint, text: expectedPassword);
    await enterTextIntoFormField(tester,
        fieldLabelOrHint: localizations.passwordNewConfirmationHint, text: expectedPassword);

    // Press "change password" button
    final changePasswordBtn = find.widgetWithText(ElevatedButton, localizations.buttonPasswordChange);
    await tester.ensureVisible(changePasswordBtn);
    await tester.tap(changePasswordBtn);
    await tester.pumpAndSettle();

    // Check that onPasswordReset was called with the expected information
    expect(newPassword, equals(expectedPassword));
  });

  testWidgets('resetPasswordWhenResetCodeAlreadyKnown', (WidgetTester tester) async {
    final expectedEmail = "forgetfull@user.de";
    final expectedResetCode = "R3S3T";
    final expectedPassword = "newpassword";

    bool resetCodeRequested = false;
    String? newPassword;
    final RestClientStub client = new RestClientStub(
      onPasswordResetRequest: (emailAddress) {
        resetCodeRequested = expectedEmail == emailAddress;
      },
      onPasswordReset: (emailAddress, resetCode, password) {
        if (emailAddress == expectedEmail && resetCode == expectedResetCode) {
          newPassword = password;
        }
      },
    );

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: Update.none());

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    // Press "password forgotten" button
    var passwordForgottenBtn = find.widgetWithText(OutlinedButton, localizations.buttonPasswordForgotten);
    await tester.ensureVisible(passwordForgottenBtn);
    await tester.tap(passwordForgottenBtn);
    await tester.pumpAndSettle();

    // Press "enter reset code" button instead of entering an email address
    await tester.tap(find.widgetWithText(OutlinedButton, localizations.buttonPasswordResetCode));
    await tester.pumpAndSettle();

    // We have not requested a code...
    expect(resetCodeRequested, isFalse);

    // Enter email address, reset code, and the new password + password confirmation
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.emailHint, text: expectedEmail);
    await enterTextIntoFormField(tester,
        fieldLabelOrHint: localizations.passwordResetCodeHint, text: expectedResetCode);
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.passwordNewHint, text: expectedPassword);
    await enterTextIntoFormField(tester,
        fieldLabelOrHint: localizations.passwordNewConfirmationHint, text: expectedPassword);

    // Press "change password" button
    final changePasswordBtn = find.widgetWithText(ElevatedButton, localizations.buttonPasswordChange);
    await tester.ensureVisible(changePasswordBtn);
    await tester.tap(changePasswordBtn);
    await tester.pumpAndSettle();

    // Check that onPasswordReset was called with the expected information
    expect(newPassword, equals(expectedPassword));
  });

  testWidgets('showCurrentVersion', (WidgetTester tester) async {
    final store = SettingsStoreStub();
    final version = Version(1, 2, 3);
    final update = Update(store, version, version, null, false);

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: update);

    await tester.pumpWidget(await makeTestableWidget(loginPage, store: store, locale: testLocale));
    await tester.pumpAndSettle();

    expect(find.text("1.2.3"), findsOneWidget);
  });

  testWidgets('showNewMinorVersionAvailable', (WidgetTester tester) async {
    final store = SettingsStoreStub();
    final version = Version(1, 2, 3);
    final latestVersion = Version(1, 3, 4);
    final update = Update(store, version, latestVersion, null, false);

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: update);

    await tester.pumpWidget(await makeTestableWidget(loginPage, store: store, locale: testLocale));
    await tester.pumpAndSettle();

    expect(find.text("1.2.3"), findsOneWidget);
    expect(find.text(localizations.newerVersionAvailable("1.3.4")), findsOneWidget);
  });

  testWidgets('doNotShowNewPatchVersionAvailable', (WidgetTester tester) async {
    final store = SettingsStoreStub();
    final version = Version(1, 2, 3);
    final latestVersion = Version(1, 2, 4);
    final update = Update(store, version, latestVersion, null, false);

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: update);

    await tester.pumpWidget(await makeTestableWidget(loginPage, store: store, locale: testLocale));
    await tester.pumpAndSettle();

    expect(find.text("1.2.3"), findsOneWidget);
    expect(find.text(localizations.newerVersionAvailable("1.2.4")), findsNothing);
  });

  testWidgets('showObligatoryUpdateAvailableIfMajorVersionChanged', (WidgetTester tester) async {
    final store = SettingsStoreStub();
    final version = Version(1, 2, 3);
    final latestVersion = Version(2, 0, 0);
    final update = Update(store, version, latestVersion, null, false);

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: update);

    await tester.pumpWidget(await makeTestableWidget(loginPage, store: store, locale: testLocale));
    await tester.pumpAndSettle();

    expect(find.text("1.2.3"), findsOneWidget);
    expect(find.text(localizations.newerVersionAvailable("2.0.0")), findsOneWidget);
    expect(find.text(localizations.newerVersionAvailableObligatoryUpdate), findsOneWidget);
  });

  testWidgets('showInfoMessageAndDismiss', (WidgetTester tester) async {
    final store = SettingsStoreStub();
    final version = Version(1, 2, 3);
    final messageStr = "Not so important message.";
    final messageNum = 1234;
    final message = InfoMessage(messageNum, InfoMessageSeverity.INFO, messageStr, null);
    final update = Update(store, version, version, message, false);

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: update);

    await tester.pumpWidget(await makeTestableWidget(loginPage, store: store, locale: testLocale));
    await tester.pumpAndSettle();

    expect(find.text(messageStr), findsOneWidget);

    final dismissBtn = find.widgetWithText(TextButton, localizations.ok);
    await tester.tap(dismissBtn);
    await tester.pumpAndSettle();

    expect(store.confirmedMessageNumber, equals(messageNum));
    expect(find.text(messageStr), findsNothing);
  });

  testWidgets('showCriticalMessageWithCustomDismissBtnLabelAndDismiss', (WidgetTester tester) async {
    final store = SettingsStoreStub();
    final version = Version(1, 2, 3);
    final messageStr = "Important message.";
    final dismissLabel = "Go away pls";
    final messageNum = 1234;
    final message = InfoMessage(messageNum, InfoMessageSeverity.CRITICAL, messageStr, dismissLabel);
    final update = Update(store, version, version, message, false);

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: update);

    await tester.pumpWidget(await makeTestableWidget(loginPage, store: store, locale: testLocale));
    await tester.pumpAndSettle();

    expect(find.text(messageStr), findsOneWidget);

    final dismissBtn = find.widgetWithText(OutlinedButton, dismissLabel);
    await tester.tap(dismissBtn);
    await tester.pumpAndSettle();

    expect(store.confirmedMessageNumber, equals(messageNum));
    expect(find.text(messageStr), findsNothing);
  });

  testWidgets('doNotShowDismissedInfoMessage', (WidgetTester tester) async {
    final store = SettingsStoreStub();
    final version = Version(1, 2, 3);
    final messageStr = "Not so important message.";
    final messageNum = 1234;
    final message = InfoMessage(messageNum, InfoMessageSeverity.INFO, messageStr, null);
    final update = Update(store, version, version, message, true);

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: update);

    await tester.pumpWidget(await makeTestableWidget(loginPage, store: store, locale: testLocale));
    await tester.pumpAndSettle();

    expect(find.text(messageStr), findsNothing);
  });

  testWidgets('doNotShowDismissedCriticalMessage', (WidgetTester tester) async {
    final store = SettingsStoreStub();
    final version = Version(1, 2, 3);
    final messageStr = "Important message.";
    final messageNum = 1234;
    final message = InfoMessage(messageNum, InfoMessageSeverity.CRITICAL, messageStr, null);
    final update = Update(store, version, version, message, true);

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: update);

    await tester.pumpWidget(await makeTestableWidget(loginPage, store: store, locale: testLocale));
    await tester.pumpAndSettle();

    expect(find.text(messageStr), findsNothing);
  });
}
