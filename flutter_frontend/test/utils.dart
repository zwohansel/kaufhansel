import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/settings/settings_store.dart';
import 'package:kaufhansel_client/settings/settings_store_widget.dart';

import 'rest_client_stub.dart';
import 'settings_store_stub.dart';

Future<Widget> makeBasicTestableWidget(Widget child, {Locale? locale}) async {
  final supportedLocale = locale ?? Locale("de");
  return MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [supportedLocale],
      locale: supportedLocale,
      home: child,
    ),
  );
}

Future<Widget> makeTestableWidget(Widget child, {SettingsStore? store, RestClient? restClient, Locale? locale}) async {
  return makeBasicTestableWidget(
    RestClientWidget(
      restClient ?? RestClientStub(),
      child: SettingsStoreWidget(
        store ?? SettingsStoreStub(),
        child: child,
      ),
    ),
  );
}

Future<void> enterText(WidgetTester tester,
    {required Type widgetType, required String fieldLabelOrHint, required String text}) async {
  final field = find.widgetWithText(widgetType, fieldLabelOrHint);
  expect(field, findsOneWidget);
  await tester.enterText(field, text);
}

Future<void> enterTextIntoFormField(WidgetTester tester,
    {required String fieldLabelOrHint, required String text}) async {
  return enterText(tester, widgetType: TextFormField, fieldLabelOrHint: fieldLabelOrHint, text: text);
}
