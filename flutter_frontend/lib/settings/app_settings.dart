import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/utils/update_check.dart';
import 'package:kaufhansel_client/widgets/confirm_dialog.dart';
import 'package:kaufhansel_client/widgets/error_dialog.dart';
import 'package:kaufhansel_client/widgets/link.dart';

import '../widgets/title_widget.dart';

class AppSettings extends StatefulWidget {
  final ShoppingListUserInfo _userInfo;
  final Future<void> Function() _onLogOut;
  final Future<void> Function() _onDeleteAccount;

  AppSettings(
      {required ShoppingListUserInfo userInfo,
      required Future<void> Function() onLogOut,
      required Future<void> Function() onDeleteAccount})
      : _userInfo = userInfo,
        _onLogOut = onLogOut,
        _onDeleteAccount = onDeleteAccount;

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  final ScrollController _scrollController = ScrollController();
  String? _version;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _setVersion();
  }

  void _setVersion() async {
    final version = await getCurrentVersion();
    setState(() {
      _version = version.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_loading,
      child: Scaffold(
        appBar: AppBar(
          title: TitleWidget(AppLocalizations.of(context).appTitle),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgressBar(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 0, maxWidth: 600),
                  child: Scrollbar(
                    controller: _scrollController,
                    child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildAppSettingsCard(context),
                              _buildAppInfoCard(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _buildAppSettingsCard(BuildContext context) {
    return Card(
      child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context).appSettingsTitle(widget._userInfo.username),
                  style: Theme.of(context).textTheme.headlineSmall?.apply(fontFamilyFallback: ['NotoColorEmoji'])),
              SizedBox(height: 12),
              Text(AppLocalizations.of(context).appSettingsYourEmail(widget._userInfo.emailAddress)),
              SizedBox(height: 24),
              OutlinedButton(
                child: Text(AppLocalizations.of(context).appSettingsLogOut),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                ),
                onPressed: _loading ? null : _onLogOut,
              ),
              SizedBox(height: 12),
              OutlinedButton(
                  child: Text(AppLocalizations.of(context).appSettingsDeleteAccount),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                  ),
                  onPressed: _loading ? null : () => _onDeleteAccount()),
            ],
          )),
    );
  }

  Card _buildAppInfoCard(BuildContext context) {
    return Card(
      child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context).appSettingsAboutTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.apply(fontFamilyFallback: ['NotoColorEmoji'])),
              SizedBox(height: 12),
              Builder(
                builder: (context) => _buildVersion(context),
              ),
              SizedBox(height: 12),
              Link(AppLocalizations.of(context).privacyPolicyLink, text: AppLocalizations.of(context).privacyPolicy),
              SizedBox(height: 12),
              Link(AppLocalizations.of(context).disclaimerLink, text: AppLocalizations.of(context).disclaimer),
              SizedBox(height: 12),
              Link(AppLocalizations.of(context).zwoHanselKaufhanselLandingPageLink,
                  text: AppLocalizations.of(context).zwoHanselKaufhanselLandingPageLinkInfo),
              SizedBox(height: 12),
              Link(AppLocalizations.of(context).zwoHanselKaufhanselGithubLink,
                  text: AppLocalizations.of(context).zwoHanselKaufhanselGithubLinkInfo),
              SizedBox(height: 12),
              Link(AppLocalizations.of(context).zwoHanselPageLink,
                  text: AppLocalizations.of(context).zwoHanselPageLinkInfo),
            ],
          )),
    );
  }

  _onLogOut() {
    setState(() => _loading = true);
    try {
      widget._onLogOut();
      Navigator.pop(context);
    } on Exception catch (e) {
      log("Could not perform logout.", error: e);
      showErrorDialogForException(context, e, altText: AppLocalizations.of(context).exceptionLogOutFailed);
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
      if (deleteAccount ?? false) {
        await widget._onDeleteAccount();
        await showCustomErrorDialog(
            context,
            Text(AppLocalizations.of(context).appSettingsAccountDeletedText, textAlign: TextAlign.center),
            AppLocalizations.of(context).ok,
            emoji: AppLocalizations.of(context).appSettingsAccountDeletedEmoji);
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      log("Could not delete account", error: e);
      showErrorDialogForException(context, e, altText: AppLocalizations.of(context).exceptionDeleteListFailed);
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
    final version = _version;
    if (version != null) {
      return Text(version);
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
