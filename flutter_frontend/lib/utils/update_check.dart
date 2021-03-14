import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/settings/settings_store.dart';
import 'package:kaufhansel_client/utils/semantic_versioning.dart';
import 'package:kaufhansel_client/widgets/confirm_dialog.dart';
import 'package:package_info/package_info.dart';

import '../model.dart';

class Update {
  final SettingsStore _settingsStore;
  final Version _currentVersion;
  final Version _latestVersion;
  final InfoMessage _message;
  bool _messageConfirmed;

  Update(this._settingsStore, this._currentVersion, this._latestVersion, this._message, this._messageConfirmed);

  factory Update.none() {
    return Update(null, null, null, null, false);
  }

  bool hasCurrentVersion() {
    return _currentVersion != null;
  }

  bool hasLatestVersion() {
    return _latestVersion != null;
  }

  bool isNewVersionAvailable() {
    if (!hasCurrentVersion() || !hasLatestVersion()) {
      return false;
    }

    // Ignore patch version changes since they only indicate backend changes
    return _latestVersion.isMoreRecentIgnoringPatchLevelThan(_currentVersion);
  }

  bool isBreakingChange() {
    return isNewVersionAvailable() && !_latestVersion.isCompatibleTo(_currentVersion);
  }

  Version get currentVersion => _currentVersion;
  Version get latestVersion => _latestVersion;

  bool hasInfoMessage() {
    return _message != null && !_messageConfirmed;
  }

  bool isCritical() {
    return (hasInfoMessage() && _message.severity == InfoMessageSeverity.CRITICAL) || isBreakingChange();
  }

  InfoMessage get infoMessage => _message;

  void confirmMessage() {
    _messageConfirmed = true;
    if (_message != null) {
      _settingsStore.confirmInfoMessage(_message.messageNumber);
    }
  }
}

Future<Optional<Update>> checkForUpdate(
  BuildContext context,
  RestClient client,
  SettingsStore store,
  Version currentVersion,
) async {
  while (true) {
    try {
      final backendInfo = await client.getBackendInfo();
      final messageConfirmed =
          backendInfo.message != null ? await store.isInfoMessageConfirmed(backendInfo.message.messageNumber) : false;

      return Optional(Update(store, currentVersion, backendInfo.version, backendInfo.message, messageConfirmed));
    } on Exception catch (e) {
      log("Failed to fetch backend info.", error: e);
      if (await _askUserIfWeShouldTryAgain(context)) {
        await Future.delayed(Duration(seconds: 5)); // Don't let the user DDOS the server
      } else {
        return Optional.empty();
      }
    }
  }
}

Future<bool> _askUserIfWeShouldTryAgain(BuildContext context) {
  final locale = AppLocalizations.of(context);
  return showConfirmDialog(context, locale.exceptionUpdateCheckFailed,
      confirmBtnLabel: locale.tryAgain, cancelBtnLabel: locale.dontCare, confirmBtnColor: null);
}

Future<Version> getCurrentVersion() async {
  try {
    final info = await PackageInfo.fromPlatform();
    return Version.fromString(info.version);
  } on Exception catch (e) {
    log("Could not get app version.", error: e);
    return null;
  }
}
