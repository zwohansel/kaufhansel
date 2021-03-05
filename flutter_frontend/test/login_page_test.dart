import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/login_page.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/settings/settings_store.dart';
import 'package:kaufhansel_client/settings/settings_store_widget.dart';
import 'package:kaufhansel_client/utils/update_check.dart';

import 'rest_client_stub.dart';
import 'settings_store_stub.dart';

const testLocale = Locale("de");

Future<Widget> makeTestableWidget(Widget child, {SettingsStore store, RestClient restClient}) async {
  return MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      home: Localizations(
        locale: testLocale,
        delegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate
        ],
        child: RestClientWidget(
          restClient ?? RestClientStub(),
          child: SettingsStoreWidget(
            store ?? SettingsStoreStub(),
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('SuccessfulLogin', (WidgetTester tester) async {
    final user = new User(new ShoppingListUserInfo("12345", "TestUser", "test@test.de", "token"), "testpassword");

    ShoppingListUserInfo loggedInUserInfo;
    final LoginPage loginPage = new LoginPage(loggedIn: (info) => loggedInUserInfo = info, update: Update.none());

    final RestClientStub client = new RestClientStub();
    client.addUser(user);

    await tester.pumpWidget(await makeTestableWidget(loginPage, restClient: client));

    await tester.pumpAndSettle();

    final localizations = await AppLocalizations.load(testLocale);

    var emailInput = find.widgetWithText(TextFormField, localizations.emailHint);
    expect(emailInput, findsOneWidget);
    await tester.enterText(emailInput, user.info.emailAddress);

    var passwordInput = find.widgetWithText(TextFormField, localizations.passwordHint);
    expect(passwordInput, findsOneWidget);
    await tester.enterText(passwordInput, user.password);

    await tester.tap(find.widgetWithText(ElevatedButton, localizations.buttonLogin));

    await tester.pumpAndSettle();

    expect(loggedInUserInfo, equals(user.info));
  });
}
