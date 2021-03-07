import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/login_page.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/utils/update_check.dart';

import 'rest_client_stub.dart';
import 'utils.dart';

Future<void> enterTextIntoFormField(WidgetTester tester,
    {@required String fieldLabelOrHint, @required String text}) async {
  final field = find.widgetWithText(TextFormField, fieldLabelOrHint);
  expect(field, findsOneWidget);
  await tester.enterText(field, text);
}

void main() {
  const testLocale = Locale("de");
  AppLocalizations localizations;

  setUp(() async {
    localizations = await AppLocalizations.load(testLocale);
  });

  testWidgets('SuccessfulLogin', (WidgetTester tester) async {
    final RestClientStub client = new RestClientStub();

    // Create a registered user
    final user = new User(new ShoppingListUserInfo("12345", "TestUser", "test@test.de", "token"), "testpassword");
    client.addUser(user);

    ShoppingListUserInfo loggedInUserInfo;
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

    ShoppingListUserInfo loggedInUserInfo;
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

  testWidgets('fullRegistration', (WidgetTester tester) async {
    final inviteCode = "INV1T3";
    final expectedEmail = "new@user.de";
    final expectedUser = "NewUser";
    final expectedPassword = "12345678";

    String actualUserName;
    String actualPassword;
    String actualEmail;
    final RestClientStub client = new RestClientStub(onRegister: (userName, password, {emailAddress}) {
      actualUserName = userName;
      actualPassword = password;
      actualEmail = emailAddress;
      return RegistrationResult(RegistrationResultStatus.SUCCESS);
    });

    // Add invite code for full registration
    client.addInviteCode(inviteCode, RegistrationProcessType.FULL_REGISTRATION);

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: Update.none());

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    // Press register button
    await tester.tap(find.widgetWithText(OutlinedButton, localizations.buttonRegister));
    await tester.pumpAndSettle();

    // Enter invite code
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.invitationCodeHint, text: inviteCode);

    // Press next button
    await tester.tap(find.widgetWithText(ElevatedButton, localizations.buttonNext));
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

  testWidgets('registrationWithoutEMail', (WidgetTester tester) async {
    final inviteCode = "INV1T3";
    final expectedUser = "NewUser";
    final expectedPassword = "12345678";

    String actualUserName;
    String actualPassword;
    final RestClientStub client = new RestClientStub(onRegister: (userName, password, {emailAddress}) {
      actualUserName = userName;
      actualPassword = password;
      return RegistrationResult(RegistrationResultStatus.SUCCESS);
    });

    // Add invite code for full registration
    client.addInviteCode(inviteCode, RegistrationProcessType.WITHOUT_EMAIL);

    final LoginPage loginPage = new LoginPage(loggedIn: (info) {}, update: Update.none());

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client, locale: testLocale));
    await tester.pumpAndSettle();

    // Press register button
    await tester.tap(find.widgetWithText(OutlinedButton, localizations.buttonRegister));
    await tester.pumpAndSettle();

    // Enter invite code
    await enterTextIntoFormField(tester, fieldLabelOrHint: localizations.invitationCodeHint, text: inviteCode);

    // Press next button
    await tester.tap(find.widgetWithText(ElevatedButton, localizations.buttonNext));
    await tester.pumpAndSettle();

    // There should be no input field for the email address
    expect(find.widgetWithText(TextFormField, localizations.emailHint), findsNothing);

    // Enter user name, password and password confirmation
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
    expect(actualUserName, equals(expectedUser));
    expect(actualPassword, equals(expectedPassword));

    // Check that the registration success message is shown
    expect(find.text(localizations.registrationSuccessful), findsOneWidget);
  });

  testWidgets('resetPassword', (WidgetTester tester) async {
    final expectedEmail = "forgetfull@user.de";
    final expectedResetCode = "R3S3T";
    final expectedPassword = "newpassword";

    bool resetCodeRequested = false;
    String newPassword;
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
    String newPassword;
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
}
