import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/settings/settings_store_widget.dart';
import 'package:kaufhansel_client/utils/input_validation.dart';
import 'package:kaufhansel_client/utils/update_check.dart';
import 'package:kaufhansel_client/widgets/link.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/error_dialog.dart';

class LoginPage extends StatefulWidget {
  final bool _enabled;
  final Update _update;
  final void Function(ShoppingListUserInfo) _loggedIn;

  const LoginPage({@required void Function(ShoppingListUserInfo) loggedIn, @required Update update, enabled = true})
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
  final _loginFormKey = GlobalKey<FormState>();
  final _checkInviteCodeFormKey = GlobalKey<FormState>();
  final _registerFullFormKey = GlobalKey<FormState>();
  final _registerWithoutEmailFormKey = GlobalKey<FormState>();
  final _requestPasswordResetFormKey = GlobalKey<FormState>();
  final _resetPasswordFormKey = GlobalKey<FormState>();

  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _userEmailAddressController = TextEditingController();
  final _setPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _resetPasswordCodeController = TextEditingController();

  final _tapRecognizer = TapGestureRecognizer();

  _PageMode _pageMode = _PageMode.LOGIN;

  bool _loading = false;
  bool _inviteCodeInvalid = false;
  bool _emailAddressInvalid = false;
  bool _passwordInvalid = false;
  bool _obscurePassword = true;
  bool _showInfo = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userEmailAddressController.addListener(() {
      if (_emailAddressInvalid) {
        setState(() => _emailAddressInvalid = false);
        _loginFormKey.currentState?.validate();
        _registerFullFormKey.currentState?.validate();
      }
    });
    _inviteCodeController.addListener(() {
      if (_inviteCodeInvalid) {
        setState(() => _inviteCodeInvalid = false);
        _checkInviteCodeFormKey.currentState.validate();
      }
    });
    _setPasswordController.addListener(() {
      if (_passwordInvalid) {
        setState(() => _passwordInvalid = false);
        _loginFormKey.currentState?.validate();
        _registerFullFormKey.currentState?.validate();
        _registerWithoutEmailFormKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    _inviteCodeController.dispose();
    _userEmailAddressController.dispose();
    _setPasswordController.dispose();
    _confirmPasswordController.dispose();
    _resetPasswordCodeController.dispose();
    _tapRecognizer.dispose();
    super.dispose();
  }

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
                        size: Theme.of(context).textTheme.headline3.fontSize,
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
          widget._update.infoMessage.message,
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
                                  primary: _getInfoMessageBtnColor(),
                                  side: BorderSide(color: _getInfoMessageBtnColor())),
                              onPressed: () => setState(() => _confirmMessage()),
                              child: Text(widget._update.infoMessage.dismissLabel ?? AppLocalizations.of(context).ok)))
                      : TextButton(
                          style: TextButton.styleFrom(
                            primary: _getInfoMessageBtnColor(),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => setState(() => _confirmMessage()),
                          child: Text(widget._update.infoMessage.dismissLabel ?? AppLocalizations.of(context).ok),
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

  TextStyle _getInfoMessageTextStyle() {
    if (widget._update.isCritical()) {
      return Theme.of(context).textTheme.bodyText1.apply(color: Colors.white);
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
        return _buildRegistrationFullForm();
      case _PageMode.REGISTRATION_WITHOUT_EMAIL:
        return _buildRegistrationWithoutEmailForm();
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

  Form _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _userEmailAddressController,
                  enabled: !_isLoading(),
                  autofillHints: !_isLoading() ? [AutofillHints.username] : null,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).emailHint,
                  ),
                  validator: (address) {
                    if (!isValidEMailAddress(address)) {
                      return AppLocalizations.of(context).emailInvalid;
                    }
                    return null;
                  },
                ),
                TextFormField(
                    controller: _passwordController,
                    enabled: !_isLoading(),
                    autofillHints: !_isLoading() ? [AutofillHints.password] : null,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: _obscurePassword ? Icon(Icons.remove_red_eye) : Icon(Icons.remove_red_eye_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      hintText: AppLocalizations.of(context).passwordHint,
                    ),
                    obscureText: _obscurePassword,
                    validator: (password) {
                      if (password.isEmpty) {
                        return AppLocalizations.of(context).passwordEmpty;
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _login()),
              ],
            ),
            Padding(
                padding: EdgeInsets.only(top: 15),
                child: ElevatedButton(
                    child: Text(AppLocalizations.of(context).buttonLogin), onPressed: _isLoading() ? null : _login)),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: OutlinedButton(
                  child: Text(AppLocalizations.of(context).buttonRegister),
                  onPressed: _isLoading() ? null : () => setState(() => _pageMode = _PageMode.CHECK_INVITE)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: OutlinedButton(
                  child: Text(AppLocalizations.of(context).buttonPasswordForgotten),
                  onPressed: _isLoading() ? null : () => setState(() => _pageMode = _PageMode.RESET_PASSWORD_REQUEST)),
            ),
          ],
        ),
      ),
    );
  }

  Form _buildCheckInviteCodeForm() {
    return Form(
      key: _checkInviteCodeFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _inviteCodeController,
            enabled: !_isLoading(),
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(hintText: AppLocalizations.of(context).invitationCodeHint),
            onFieldSubmitted: (_) => _checkInviteCode(),
            validator: (code) {
              if (code.trim().isEmpty) {
                return AppLocalizations.of(context).invitationCodeEmpty;
              } else if (_inviteCodeInvalid) {
                return AppLocalizations.of(context).invitationCodeInvalid;
              }
              return null;
            },
          ),
          Padding(
              padding: EdgeInsets.only(top: 15),
              child: ElevatedButton(
                  child: Text(AppLocalizations.of(context).buttonNext),
                  onPressed: _isLoading() ? null : _checkInviteCode)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text(AppLocalizations.of(context).buttonBackToLogin),
                onPressed: _isLoading() ? null : () => setState(() => _pageMode = _PageMode.LOGIN)),
          ),
        ],
      ),
    );
  }

  void _checkInviteCode() async {
    if (!_checkInviteCodeFormKey.currentState.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      RegistrationProcessType registrationProcessType =
          await RestClientWidget.of(context).checkInviteCode(_inviteCodeController.text);
      switch (registrationProcessType) {
        case RegistrationProcessType.FULL_REGISTRATION:
          setState(() => _pageMode = _PageMode.REGISTRATION_FULL);
          break;
        case RegistrationProcessType.WITHOUT_EMAIL:
          setState(() => _pageMode = _PageMode.REGISTRATION_WITHOUT_EMAIL);
          break;
        case RegistrationProcessType.INVALID:
        default:
          setState(() => _inviteCodeInvalid = true);
          _checkInviteCodeFormKey.currentState.validate();
      }
    } on Exception catch (e) {
      log("Get registration process type failed.", error: e);
      showErrorDialog(context, AppLocalizations.of(context).exceptionGeneralTryAgainLater);
    } finally {
      setState(() => _loading = false);
    }
  }

  Form _buildRegistrationFullForm() {
    return Form(
      key: _registerFullFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _userNameController,
            enabled: !_isLoading(),
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: AppLocalizations.of(context).userNameHint),
            validator: (userName) {
              if (userName.trim().isEmpty) {
                return AppLocalizations.of(context).userNameInvalid;
              }
              return null;
            },
          ),
          TextFormField(
            controller: _userEmailAddressController,
            enabled: !_isLoading(),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).emailHint,
            ),
            validator: (address) {
              if (!isValidEMailAddress(address)) {
                return AppLocalizations.of(context).emailInvalid;
              }
              if (_emailAddressInvalid) {
                return AppLocalizations.of(context).emailAlreadyInUse;
              }
              return null;
            },
          ),
          TextFormField(
            controller: _setPasswordController,
            enabled: !_isLoading(),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).passwordHint,
            ),
            obscureText: true,
            validator: (password) {
              if (password.length < 8) {
                return AppLocalizations.of(context).passwordToShort;
              }
              if (_passwordInvalid) {
                return AppLocalizations.of(context).passwordInvalid;
              }
              return null;
            },
          ),
          TextFormField(
            controller: _confirmPasswordController,
            enabled: !_isLoading(),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).passwordConfirmationHint,
            ),
            obscureText: true,
            validator: (password) {
              if (password.isEmpty || password != _setPasswordController.text) {
                return AppLocalizations.of(context).passwordConfirmationInvalid;
              }
              return null;
            },
            onFieldSubmitted: (_) => _registerFull(),
          ),
          SizedBox(
            height: 10,
          ),
          _buildConsentCheckBox(),
          Padding(
              padding: EdgeInsets.only(top: 15),
              child: ElevatedButton(
                  child: Text(AppLocalizations.of(context).buttonRegister),
                  onPressed: _isLoading() ? null : _registerFull)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text(AppLocalizations.of(context).buttonBackToLogin),
                onPressed: _isLoading() ? null : () => setState(() => _pageMode = _PageMode.LOGIN)),
          ),
        ],
      ),
    );
  }

  FormField<bool> _buildConsentCheckBox() {
    return FormField<bool>(
      validator: (checked) {
        if (!checked) {
          return "";
        }
        return null;
      },
      initialValue: false,
      builder: (FormFieldState<bool> state) {
        final textStyle =
            state.hasError ? TextStyle(color: Theme.of(context).errorColor) : Theme.of(context).textTheme.bodyText1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: state.value,
              onChanged: state.didChange,
              visualDensity: VisualDensity.compact,
            ),
            SizedBox(width: 10),
            Flexible(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: AppLocalizations.of(context).registrationConsentFirstPart, style: textStyle),
                    TextSpan(
                        text: AppLocalizations.of(context).privacyPolicy,
                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        recognizer: _tapRecognizer
                          ..onTap = () => launch(AppLocalizations.of(context).privacyPolicyLink)),
                    TextSpan(text: AppLocalizations.of(context).registrationConsentMiddlePart, style: textStyle),
                    TextSpan(
                        text: AppLocalizations.of(context).disclaimer,
                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        recognizer: _tapRecognizer..onTap = () => launch(AppLocalizations.of(context).disclaimerLink)),
                    TextSpan(text: AppLocalizations.of(context).registrationConsentLastPart, style: textStyle),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Form _buildRegistrationWithoutEmailForm() {
    return Form(
      key: _registerWithoutEmailFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _userNameController,
            enabled: !_isLoading(),
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: AppLocalizations.of(context).userNameHint),
            validator: (userName) {
              if (userName.trim().isEmpty) {
                return AppLocalizations.of(context).userNameInvalid;
              }
              return null;
            },
          ),
          TextFormField(
            controller: _setPasswordController,
            enabled: !_isLoading(),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).passwordHint,
            ),
            obscureText: true,
            validator: (password) {
              if (password.length < 8) {
                return AppLocalizations.of(context).passwordToShort;
              }
              if (_passwordInvalid) {
                return AppLocalizations.of(context).passwordInvalid;
              }
              return null;
            },
          ),
          TextFormField(
            controller: _confirmPasswordController,
            enabled: !_isLoading(),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).passwordConfirmationHint,
            ),
            obscureText: true,
            validator: (password) {
              if (password.isEmpty || password != _setPasswordController.text) {
                return AppLocalizations.of(context).passwordConfirmationInvalid;
              }
              return null;
            },
            onFieldSubmitted: (_) => _registerWithoutEmail(),
          ),
          SizedBox(
            height: 10,
          ),
          _buildConsentCheckBox(),
          Padding(
              padding: EdgeInsets.only(top: 15),
              child: ElevatedButton(
                  child: Text(AppLocalizations.of(context).buttonRegister),
                  onPressed: _isLoading() ? null : _registerWithoutEmail)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text(AppLocalizations.of(context).buttonBackToLogin),
                onPressed: _isLoading() ? null : () => setState(() => _pageMode = _PageMode.LOGIN)),
          ),
        ],
      ),
    );
  }

  Form _buildRequestPasswordResetForm() {
    return Form(
      key: _requestPasswordResetFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _userEmailAddressController,
            enabled: !_isLoading(),
            decoration: InputDecoration(hintText: AppLocalizations.of(context).emailHint),
            onFieldSubmitted: (_) => _requestPasswordReset(),
            validator: (emailAddress) {
              if (!isValidEMailAddress(emailAddress)) {
                return AppLocalizations.of(context).emailInvalid;
              }
              return null;
            },
          ),
          Padding(
              padding: EdgeInsets.only(top: 15),
              child: ElevatedButton(
                  child: Text(AppLocalizations.of(context).buttonPasswordReset),
                  onPressed: _isLoading() ? null : _requestPasswordReset)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text(AppLocalizations.of(context).buttonPasswordResetCode),
                onPressed: _isLoading() ? null : () => setState(() => _pageMode = _PageMode.RESET_PASSWORD)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text(AppLocalizations.of(context).buttonBackToLogin),
                onPressed: _isLoading() ? null : () => setState(() => _pageMode = _PageMode.LOGIN)),
          ),
        ],
      ),
    );
  }

  void _requestPasswordReset() async {
    if (!_requestPasswordResetFormKey.currentState.validate()) {
      return;
    }
    setState(() => _loading = true);

    try {
      await RestClientWidget.of(context).requestPasswordReset(_userEmailAddressController.text);
      setState(() => _pageMode = _PageMode.RESET_PASSWORD);
    } on Exception catch (e) {
      log("Reset password failed.", error: e);
      showErrorDialog(context, AppLocalizations.of(context).exceptionGeneralTryAgainLater);
    } finally {
      setState(() => _loading = false);
    }
  }

  Form _buildResetPasswordForm() {
    return Form(
      key: _resetPasswordFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          Text(AppLocalizations.of(context).passwordResetInfo),
          TextFormField(
            controller: _userEmailAddressController,
            enabled: !_isLoading(),
            decoration: InputDecoration(hintText: AppLocalizations.of(context).emailHint),
            onFieldSubmitted: (_) => _requestPasswordReset(),
            validator: (emailAddress) {
              if (!isValidEMailAddress(emailAddress)) {
                return AppLocalizations.of(context).emailInvalid;
              }
              return null;
            },
          ),
          TextFormField(
            controller: _resetPasswordCodeController,
            enabled: !_isLoading(),
            decoration: InputDecoration(hintText: AppLocalizations.of(context).passwordResetCodeHint),
            onFieldSubmitted: (_) => _resetPassword(),
            validator: (code) {
              if (code.isEmpty) {
                return AppLocalizations.of(context).passwordResetCodeInvalid;
              }
              return null;
            },
          ),
          TextFormField(
            controller: _setPasswordController,
            enabled: !_isLoading(),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).passwordNewHint,
            ),
            obscureText: true,
            validator: (password) {
              if (password.length < 8) {
                return AppLocalizations.of(context).passwordToShort;
              }
              if (_passwordInvalid) {
                return AppLocalizations.of(context).passwordInvalid;
              }
              return null;
            },
          ),
          TextFormField(
            controller: _confirmPasswordController,
            enabled: !_isLoading(),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).passwordNewConfirmationHint,
            ),
            obscureText: true,
            validator: (password) {
              if (password.isEmpty || password != _setPasswordController.text) {
                return AppLocalizations.of(context).passwordNewConfirmationInvalid;
              }
              return null;
            },
            onFieldSubmitted: (_) => _resetPassword(),
          ),
          Padding(
              padding: EdgeInsets.only(top: 15),
              child: ElevatedButton(
                  child: Text(AppLocalizations.of(context).buttonPasswordChange),
                  onPressed: _isLoading() ? null : _resetPassword)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text(AppLocalizations.of(context).buttonBackToLogin),
                onPressed: _isLoading() ? null : () => setState(() => _pageMode = _PageMode.LOGIN)),
          ),
        ],
      ),
    );
  }

  void _resetPassword() async {
    if (!_resetPasswordFormKey.currentState.validate()) {
      return;
    }
    setState(() => _loading = true);

    try {
      await RestClientWidget.of(context).resetPassword(
          _userEmailAddressController.text, _resetPasswordCodeController.text, _confirmPasswordController.text);
      setState(() => _pageMode = _PageMode.LOGIN);
      _showPasswordResetSuccessMessage();
    } on Exception catch (e) {
      log("Set new password failed.", error: e);
      showErrorDialog(context, AppLocalizations.of(context).exceptionResetPassword);
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

  Widget _buildProgressBar(BuildContext context) {
    if (_isLoading()) {
      return LinearProgressIndicator(minHeight: 5, backgroundColor: Theme.of(context).scaffoldBackgroundColor);
    } else {
      return SizedBox(height: 5);
    }
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

  void _login() async {
    if (!_loginFormKey.currentState.validate()) {
      return;
    }
    setState(() => _loading = true);

    try {
      final client = RestClientWidget.of(context);
      ShoppingListUserInfo userInfo = await client.login(_userEmailAddressController.text, _passwordController.text);
      if (userInfo != null) {
        await SettingsStoreWidget.of(context).saveUserInfo(userInfo);
        widget._loggedIn(userInfo);
      } else {
        showErrorDialog(context, AppLocalizations.of(context).exceptionWrongCredentials);
      }
    } on SocketException catch (e) {
      if (e.osError.errorCode == 111 && Platform.isLinux || Platform.isAndroid) {
        showErrorDialog(context, AppLocalizations.of(context).exceptionNoInternet);
      } else {
        showErrorDialog(context, AppLocalizations.of(context).exceptionGeneralComputerSays + e.osError.message);
      }
    } on TimeoutException {
      showErrorDialog(context, AppLocalizations.of(context).exceptionConnectionTimeout);
    } catch (e) {
      showErrorDialog(context, AppLocalizations.of(context).exceptionGeneralComputerSays + e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _registerFull() async {
    if (!_registerFullFormKey.currentState.validate()) {
      return;
    }
    setState(() => _loading = true);

    try {
      final registration = await RestClientWidget.of(context).register(
          _userNameController.text, _setPasswordController.text, _inviteCodeController.text,
          emailAddress: _userEmailAddressController.text);

      if (registration.isSuccess()) {
        setState(() => _pageMode = _PageMode.LOGIN);
        _showFullRegistrationSuccessMessage(_userEmailAddressController.text);
        _userEmailAddressController.clear();
        _setPasswordController.clear();
        _confirmPasswordController.clear();
        _inviteCodeController.clear();
      } else if (registration.isInviteCodeInvalid()) {
        setState(() {
          _inviteCodeInvalid = true;
          _pageMode = _PageMode.CHECK_INVITE;
        });
        SchedulerBinding.instance.addPostFrameCallback((_) => _checkInviteCodeFormKey.currentState.validate());
      } else if (registration.isEMailAddressInvalid()) {
        setState(() => _emailAddressInvalid = true);
        _registerFullFormKey.currentState.validate();
      } else if (registration.isPasswordInvalid()) {
        setState(() => _passwordInvalid = true);
        _registerFullFormKey.currentState.validate();
      } else {
        showErrorDialog(context, AppLocalizations.of(context).exceptionRegistrationFailedTryAgainLater);
      }
    } on Exception catch (e) {
      log("Registration failed.", error: e);
      showErrorDialog(context, AppLocalizations.of(context).exceptionGeneralTryAgainLater);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showFullRegistrationSuccessMessage(String emailAddress) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context).activationLinkSent(emailAddress)),
      duration: Duration(seconds: 15),
      action: SnackBarAction(
        label: AppLocalizations.of(context).ok,
        onPressed: () => ScaffoldMessenger.of(context).removeCurrentSnackBar(),
      ),
    ));
  }

  void _registerWithoutEmail() async {
    if (!_registerWithoutEmailFormKey.currentState.validate()) {
      return;
    }
    setState(() => _loading = true);

    try {
      final registration = await RestClientWidget.of(context)
          .register(_userNameController.text, _setPasswordController.text, _inviteCodeController.text);

      if (registration.isSuccess()) {
        setState(() => _pageMode = _PageMode.LOGIN);
        showRegistrationWithoutEmailSuccessMessage();
        _setPasswordController.clear();
        _confirmPasswordController.clear();
        _inviteCodeController.clear();
      } else if (registration.isInviteCodeInvalid()) {
        setState(() {
          _inviteCodeInvalid = true;
          _pageMode = _PageMode.CHECK_INVITE;
        });
        _checkInviteCodeFormKey.currentState.validate();
      } else if (registration.isPasswordInvalid()) {
        setState(() => _passwordInvalid = true);
        _registerWithoutEmailFormKey.currentState.validate();
      } else {
        showErrorDialog(context, AppLocalizations.of(context).exceptionRegistrationFailedTryAgainLater);
      }
    } on Exception catch (e) {
      log("Registration failed.", error: e);
      showErrorDialog(context, AppLocalizations.of(context).exceptionGeneralTryAgainLater);
    } finally {
      setState(() => _loading = false);
    }
  }

  void showRegistrationWithoutEmailSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context).registrationSuccessful),
    ));
  }
}
