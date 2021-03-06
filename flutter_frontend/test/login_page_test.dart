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
}
