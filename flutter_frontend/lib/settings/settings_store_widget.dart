import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/settings/settings_store.dart';

class SettingsStoreWidget extends InheritedWidget {
  final SettingsStore _storage;

  SettingsStoreWidget(this._storage, {required Widget child}) : super(child: child);

  static SettingsStore? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SettingsStoreWidget>()?._storage;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}
