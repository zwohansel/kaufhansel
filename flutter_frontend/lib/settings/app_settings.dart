import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/widgets/confirm_dialog.dart';
import 'package:kaufhansel_client/widgets/error_dialog.dart';
import 'package:kaufhansel_client/widgets/link.dart';
import 'package:package_info/package_info.dart';

import '../widgets/title_widget.dart';

class AppSettings extends StatefulWidget {
  final ShoppingListUserInfo _userInfo;
  final Future<void> Function() _onLogOut;
  final Future<void> Function() _onDeleteAccount;

  AppSettings(
      {@required ShoppingListUserInfo userInfo,
      @required Future<void> Function() onLogOut,
      @required Future<void> Function() onDeleteAccount})
      : _userInfo = userInfo,
        _onLogOut = onLogOut,
        _onDeleteAccount = onDeleteAccount;

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  final ScrollController _scrollController = ScrollController();
  String _version;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _setVersion();
  }

  void _setVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _version = info.version;
      });
    } on Exception catch (e) {
      log("Could not get app version.", error: e);
      setState(() {
        _version = "?.?.?";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => !_loading,
        child: Scaffold(
            appBar: AppBar(
              title: TitleWidget(AppLocalizations.of(context).appTitle),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressBar(),
                Expanded(
                  child: Scrollbar(
                      controller: _scrollController,
                      child: ListView(children: [
                        Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Card(
                                  child: Padding(
                                      padding: EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(AppLocalizations.of(context).appSettingsTitle(widget._userInfo.username),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5
                                                  .apply(fontFamilyFallback: ['NotoColorEmoji'])),
                                          SizedBox(height: 12),
                                          Text(AppLocalizations.of(context)
                                              .appSettingsYourEmail(widget._userInfo.emailAddress)),
                                          SizedBox(height: 24),
                                          OutlinedButton(
                                            child: Text(AppLocalizations.of(context).appSettingsLogOut),
                                            style: OutlinedButton.styleFrom(primary: Colors.red),
                                            onPressed: _loading ? null : _onLogOut,
                                          ),
                                          SizedBox(height: 12),
                                          OutlinedButton(
                                              child: Text(AppLocalizations.of(context).appSettingsDeleteAccount),
                                              style: OutlinedButton.styleFrom(primary: Colors.red),
                                              onPressed: _loading ? null : () => _onDeleteAccount()),
                                        ],
                                      )),
                                ),
                                SizedBox(height: 12),
                                Card(
                                  child: Padding(
                                      padding: EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(AppLocalizations.of(context).appSettingsAboutTitle,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5
                                                  .apply(fontFamilyFallback: ['NotoColorEmoji'])),
                                          SizedBox(height: 12),
                                          Builder(
                                            builder: (context) => _buildVersion(context),
                                          ),
                                          SizedBox(height: 12),
                                          Link(AppLocalizations.of(context).zwoHanselPageLink,
                                              text: AppLocalizations.of(context).zwoHanselPageLinkInfo),
                                          SizedBox(height: 12),
                                          Link(AppLocalizations.of(context).zwoHanselGithubLink,
                                              text: AppLocalizations.of(context).zwoHanselGithubLinkInfo),
                                          SizedBox(height: 12),
                                          Link(AppLocalizations.of(context).zwoHanselKaufhanselGithubLink,
                                              text: AppLocalizations.of(context).zwoHanselKaufhanselGithubLinkInfo),
                                        ],
                                      )),
                                ),
                              ],
                            ))
                      ])),
                ),
              ],
            )));
  }

  _onLogOut() {
    setState(() => _loading = true);
    try {
      widget._onLogOut();
      Navigator.pop(context);
    } catch (e) {
      showErrorDialog(context, AppLocalizations.of(context).exceptionLogOutFailed);
    } finally {
      setState(() => _loading = false);
    }
  }

  _onDeleteAccount() async {
    setState(() => _loading = true);
    try {
      final deleteAccount = await showConfirmDialog(
          context, AppLocalizations.of(context).appSettingsDeleteAccountConfirmationText,
          title: AppLocalizations.of(context).appSettingsDeleteAccountConfirmationTextTitle(widget._userInfo.username),
          confirmBtnLabel: AppLocalizations.of(context).appSettingsDeleteAccountYes,
          cancelBtnLabel: AppLocalizations.of(context).appSettingsDeleteAccountNo);
      if (deleteAccount) {
        await widget._onDeleteAccount();
        await showCustomErrorDialog(
            context,
            Text(AppLocalizations.of(context).appSettingsAccountDeletedText, textAlign: TextAlign.center),
            AppLocalizations.of(context).ok,
            emoji: AppLocalizations.of(context).appSettingsAccountDeletedEmoji);
        Navigator.pop(context);
      }
    } catch (e) {
      showErrorDialog(context, AppLocalizations.of(context).exceptionDeleteListFailed);
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildProgressBar() {
    if (_loading) {
      return LinearProgressIndicator(minHeight: 5);
    } else {
      return Container();
    }
  }

  Widget _buildVersion(BuildContext context) {
    if (_version != null) {
      return Text(_version);
    }

    final textStyle = DefaultTextStyle.of(context);
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: SizedBox(
          width: textStyle.style.fontSize,
          height: textStyle.style.fontSize,
          child: CircularProgressIndicator(),
        ));
  }
}
