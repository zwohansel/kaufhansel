import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/login/check_invite_code_form.dart';
import 'package:kaufhansel_client/login/email_password_form.dart';
import 'package:kaufhansel_client/login/registration_form.dart';
import 'package:kaufhansel_client/login/request_password_reset_form.dart';
import 'package:kaufhansel_client/login/reset_password_form.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/settings/settings_store_widget.dart';
import 'package:kaufhansel_client/utils/update_check.dart';
import 'package:kaufhansel_client/widgets/link.dart';

import '../widgets/error_dialog.dart';

class LoginPage extends StatefulWidget {
  final bool _enabled;
  final Update _update;
  final void Function(ShoppingListUserInfo) _loggedIn;

  const LoginPage({required void Function(ShoppingListUserInfo) loggedIn, required Update update, enabled = true})
      : _loggedIn = loggedIn,
        _update = update,
        _enabled = enabled;

  @override
  _LoginPageState createState() => _LoginPageState();
}

enum _PageMode {
  LOGIN,
  CHECK_INVITE,
  REGISTRATION_FULL,
  REGISTRATION_WITHOUT_EMAIL,
  RESET_PASSWORD_REQUEST,
  RESET_PASSWORD
}

class _LoginPageState extends State<LoginPage> {
  _PageMode _pageMode = _PageMode.LOGIN;
  bool _loading = false;
  String _emailAddress = "";
  String? _inviteCode;
  bool? _inviteCodeInvalid = false;
  bool _showInfo = true;

  @override
  Widget build(BuildContext context) {
    final bottomNavBarHeight = 105.0;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: bottomNavBarHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: Theme.of(context).textTheme.headline3?.fontSize,
                      ),
                      Text(
                        AppLocalizations.of(context).appTitle,
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                ),
                _buildProgressBar(context),
                Flexible(
                  child: SingleChildScrollView(child: _buildContent()),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
          height: bottomNavBarHeight,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildBottomInfos(context),
            ),
          )),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    if (_isLoading()) {
      return LinearProgressIndicator(minHeight: 5, backgroundColor: Theme.of(context).scaffoldBackgroundColor);
    } else {
      return SizedBox(height: 5);
    }
  }

  Widget _buildContent() {
    List<Widget> infoMessages = [];
    if ((widget._update.hasInfoMessage() || widget._update.isCritical()) && _showInfo) {
      final List<Widget> messages = [];

      if (widget._update.isBreakingChange()) {
        messages.add(Text(
          AppLocalizations.of(context).newerVersionAvailableObligatoryUpdate,
          style: _getInfoMessageTextStyle(),
        ));
      }

      if (widget._update.hasInfoMessage()) {
        if (messages.length > 0) {
          messages.add(SizedBox(height: 10));
        }
        messages.add(Text(
          widget._update.infoMessage?.message ?? "",
          style: _getInfoMessageTextStyle(),
        ));
      }

      infoMessages.add(
        Container(
          color: _getInfoMessageBoxColor(),
          child: Padding(
            padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...messages,
                Align(
                  alignment: Alignment.center,
                  child: widget._update.isCritical()
                      ? Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  backgroundColor: _getInfoMessageBtnColor(),
                                  side: BorderSide(color: _getInfoMessageBtnColor())),
                              onPressed: () => setState(() => _confirmMessage()),
                              child:
                                  Text(widget._update.infoMessage?.dismissLabel ?? AppLocalizations.of(context).ok)))
                      : TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: _getInfoMessageBtnColor(),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => setState(() => _confirmMessage()),
                          child: Text(widget._update.infoMessage?.dismissLabel ?? AppLocalizations.of(context).ok),
                        ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...infoMessages,
        _buildForm(),
      ],
    );
  }

  void _confirmMessage() {
    widget._update.confirmMessage();
    _showInfo = false;
  }

  Color _getInfoMessageBoxColor() {
    if (widget._update.isCritical()) {
      return Colors.redAccent.shade400;
    }
    return Theme.of(context).secondaryHeaderColor;
  }

  TextStyle? _getInfoMessageTextStyle() {
    if (widget._update.isCritical()) {
      return Theme.of(context).textTheme.bodyText1?.apply(color: Colors.white);
    }
    return Theme.of(context).textTheme.bodyText1;
  }

  Color _getInfoMessageBtnColor() {
    if (widget._update.isCritical()) {
      return Colors.white;
    }
    return Theme.of(context).primaryColor;
  }

  Widget _buildForm() {
    switch (_pageMode) {
      case _PageMode.LOGIN:
        return _buildLoginForm();
      case _PageMode.CHECK_INVITE:
        return _buildCheckInviteCodeForm();
      case _PageMode.REGISTRATION_FULL:
      case _PageMode.REGISTRATION_WITHOUT_EMAIL:
        return _buildRegistrationForm();
      case _PageMode.RESET_PASSWORD_REQUEST:
        return _buildRequestPasswordResetForm();
      case _PageMode.RESET_PASSWORD:
        return _buildResetPasswordForm();
      default:
        return Container(
          child: Text(AppLocalizations.of(context).exceptionFatal),
        );
    }
  }

  bool _isLoading() {
    return _loading || !widget._enabled;
  }

  Widget _buildLoginForm() {
    return EMailPasswordForm(
      onLogin: _login,
      enabled: !_isLoading(),
      initialEmail: _emailAddress,
      onEmailChanged: (email) => setState(() => _emailAddress = email),
      extraFormChildren: [
        SizedBox(height: 10),
        OutlinedButton(
          child: Text(AppLocalizations.of(context).buttonRegister),
          onPressed: _isLoading() ? null : () => setState(() => _pageMode = _PageMode.CHECK_INVITE),
        ),
        SizedBox(height: 10),
        OutlinedButton(
          child: Text(AppLocalizations.of(context).buttonPasswordForgotten),
          onPressed: _isLoading() ? null : () => setState(() => _pageMode = _PageMode.RESET_PASSWORD_REQUEST),
        ),
      ],
    );
  }

  void _login(String email, String password) async {
    setState(() => _loading = true);

    try {
      final client = RestClientWidget.of(context);
      ShoppingListUserInfo? userInfo = await client.login(email, password);
      final settingsStore = await SettingsStoreWidget.of(context);
      if (userInfo != null && settingsStore != null) {
        await settingsStore.saveUserInfo(userInfo);
        widget._loggedIn(userInfo);
      } else {
        showErrorDialog(context, AppLocalizations.of(context).exceptionWrongCredentials);
      }
    } on SocketException catch (e) {
      if (e.osError?.errorCode == 111 && Platform.isLinux || Platform.isAndroid) {
        showErrorDialog(context, AppLocalizations.of(context).exceptionNoInternet);
      } else {
        showErrorDialog(context, AppLocalizations.of(context).exceptionGeneralComputerSays + (e.osError?.message ?? ""));
      }
    } on TimeoutException {
      showErrorDialog(context, AppLocalizations.of(context).exceptionConnectionTimeout);
    } on Exception catch (e) {
      log("Could not login", error: e);
      showErrorDialogForException(context, e,
          altText: AppLocalizations.of(context).exceptionGeneralComputerSays + e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildCheckInviteCodeForm() {
    return CheckInviteCodeForm(
      onInviteCode: _checkInviteCode,
      initialCode: _inviteCode,
      initialCodeIsInvalid: _inviteCodeInvalid,
      enabled: !_isLoading(),
      extraFormChildren: [
        SizedBox(height: 10),
        OutlinedButton(
          child: Text(AppLocalizations.of(context).buttonBackToLogin),
          onPressed: _isLoading() ? null : _goBackToLogin,
        )
      ],
    );
  }

  Future<bool> _checkInviteCode(String code) async {
    setState(() => _loading = true);
    try {
      RegistrationProcessType registrationProcessType = await RestClientWidget.of(context).checkInviteCode(code);
      if (registrationProcessType == RegistrationProcessType.INVALID) {
        return false;
      }
      setState(() {
        if (registrationProcessType == RegistrationProcessType.FULL_REGISTRATION) {
          _pageMode = _PageMode.REGISTRATION_FULL;
        } else {
          _pageMode = _PageMode.REGISTRATION_WITHOUT_EMAIL;
        }
        _inviteCodeInvalid = null;
        _inviteCode = code;
      });
      return true;
    } on Exception catch (e) {
      log("Could not get registration process type", error: e);
      showErrorDialogForException(context, e, altText: AppLocalizations.of(context).exceptionGeneralTryAgainLater);
      return false;
    } finally {
      setState(() => _loading = false);
    }
  }

  void _goBackToLogin() {
    setState(() {
      _pageMode = _PageMode.LOGIN;
      _inviteCode = null;
      _inviteCodeInvalid = null;
    });
  }

  Widget _buildRegistrationForm() {
    return RegistrationForm(
      onRegister: _register,
      requireEmail: _pageMode == _PageMode.REGISTRATION_FULL,
      onEmailChanged: (email) => setState(() => _emailAddress = email),
      extraFormChildren: [
        SizedBox(height: 10),
        OutlinedButton(
          child: Text(AppLocalizations.of(context).buttonBackToLogin),
          onPressed: _isLoading() ? null : _goBackToLogin,
        ),
      ],
    );
  }

  Future<RegistrationResult> _register({String? email, required String password, required String userName}) async {
    setState(() => _loading = true);

    try {
      final registration = await RestClientWidget.of(context).register(
        userName,
        password,
        _inviteCode,
        emailAddress: email,
      );

      if (registration.isSuccess()) {
        setState(() {
          _pageMode = _PageMode.LOGIN;
          _inviteCode = null;
          _inviteCodeInvalid = false;
        });
      }

      if (registration.isInviteCodeInvalid()) {
        setState(() {
          _pageMode = _PageMode.CHECK_INVITE;
          _inviteCodeInvalid = true;
        });
      }

      return registration;
    } on Exception catch (e) {
      log("Registration failed.", error: e);
      return RegistrationResult.failure();
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildRequestPasswordResetForm() {
    return RequestPasswordResetForm(
      onRequestPasswordReset: _requestPasswordReset,
      initialEmail: _emailAddress,
      enabled: !_isLoading(),
      extraFormChildren: [
        SizedBox(height: 10),
        OutlinedButton(
            child: Text(AppLocalizations.of(context).buttonPasswordResetCode),
            onPressed: _isLoading() ? null : () => setState(() => _pageMode = _PageMode.RESET_PASSWORD)),
        SizedBox(height: 10),
        OutlinedButton(
            child: Text(AppLocalizations.of(context).buttonBackToLogin),
            onPressed: _isLoading() ? null : _goBackToLogin)
      ],
    );
  }

  void _requestPasswordReset(String email) async {
    setState(() => _loading = true);

    try {
      await RestClientWidget.of(context).requestPasswordReset(email);
      setState(() => _pageMode = _PageMode.RESET_PASSWORD);
    } on Exception catch (e) {
      log("Could not reset password", error: e);
      showErrorDialogForException(context, e, altText: AppLocalizations.of(context).exceptionGeneralTryAgainLater);
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildResetPasswordForm() {
    return ChangePasswordForm(
      onResetPassword: _resetPassword,
      initialEmail: _emailAddress,
      enabled: !_isLoading(),
      extraFormChildren: [
        SizedBox(height: 10),
        OutlinedButton(
          child: Text(AppLocalizations.of(context).buttonBackToLogin),
          onPressed: _isLoading() ? null : _goBackToLogin,
        ),
      ],
    );
  }

  void _resetPassword(String email, String changePasswordCode, String newPassword) async {
    setState(() => _loading = true);
    try {
      await RestClientWidget.of(context).resetPassword(email, changePasswordCode, newPassword);
      _goBackToLogin();
      _showPasswordResetSuccessMessage();
    } on Exception catch (e) {
      log("Could not set new password", error: e);
      showErrorDialogForException(context, e, altText: AppLocalizations.of(context).exceptionResetPassword);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showPasswordResetSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context).passwordChangeSuccess),
      duration: Duration(seconds: 5),
    ));
  }

  List<Widget> _buildBottomInfos(BuildContext context) {
    final zwoHanselLink =
        Link(AppLocalizations.of(context).zwoHanselPageLink, text: AppLocalizations.of(context).zwoHanselPageLinkText);
    if (!widget._update.hasCurrentVersion()) {
      return [zwoHanselLink];
    }
    if (widget._update.isNewVersionAvailable()) {
      return [
        Text(widget._update.currentVersion.toString()),
        SizedBox(height: 10),
        Link(AppLocalizations.of(context).downloadLink,
            text: AppLocalizations.of(context).newerVersionAvailable(widget._update.latestVersion.toString()),
            style: TextStyle(fontWeight: FontWeight.bold),
            trailingIcon: Icons.get_app),
        SizedBox(height: 10),
        zwoHanselLink
      ];
    }
    return [Text(widget._update.currentVersion.toString()), zwoHanselLink];
  }
}
