import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/utils/semantic_versioning.dart';
import 'package:kaufhansel_client/widgets/confirm_dialog.dart';
import 'package:package_info/package_info.dart';

import '../model.dart';

class Update {
  final Version _currentVersion;
  final Version _latestVersion;
  final InfoMessage _message;

  Update(this._currentVersion, this._latestVersion, this._message);

  factory Update.none() {
    return Update(null, null, null);
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
    return _message != null;
  }

  InfoMessage get infoMessage => _message;
}

Future<Optional<Update>> checkForUpdate(RestClient client, BuildContext context) async {
  while (true) {
    try {
      final frontendVersion = await _getVersion();
      final backendInfo = await client.getBackendInfo();

      return Optional(Update(frontendVersion, backendInfo.version, backendInfo.message));
    } on Exception catch (e) {
      log("Failed to fetch backend info.", error: e);
      final locale = AppLocalizations.of(context);
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

Future<Version> _getVersion() async {
  try {
    final info = await PackageInfo.fromPlatform();
    return Version.fromString(info.version);
  } on Exception catch (e) {
    log("Could not get app version.", error: e);
    return null;
  }
}
