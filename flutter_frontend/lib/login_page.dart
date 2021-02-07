import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/utils/input_validation.dart';
import 'package:kaufhansel_client/utils/semantic_versioning.dart';
import 'package:kaufhansel_client/widgets/confirm_dialog.dart';
import 'package:kaufhansel_client/widgets/link.dart';
import 'package:package_info/package_info.dart';

import 'widgets/error_dialog.dart';

class LoginPage extends StatefulWidget {
  final void Function(ShoppingListUserInfo) _loggedIn;

  const LoginPage({@required void Function(ShoppingListUserInfo) loggedIn}) : _loggedIn = loggedIn;

  @override
  _LoginPageState createState() => _LoginPageState();
}

const String _DownloadLink = "https://www.zwohansel.de/kaufhansel/download";

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

  _PageMode _pageMode = _PageMode.LOGIN;

  bool _loading = true;
  bool _inviteCodeInvalid = false;
  bool _emailAddressInvalid = false;
  bool _passwordInvalid = false;

  Version _frontendVersion;
  Version _backendVersion;
  String _infoMessage;
  String _infoMessageDismissLabel;

  @override
  void initState() {
    super.initState();
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
    _fetchBackendInfo();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 60),
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
                        "Kaufhansel",
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
          height: 60,
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
    if (_infoMessage != null) {
      infoMessages.add(
        Container(
          color: Theme.of(context).secondaryHeaderColor,
          child: Padding(
            padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_infoMessage),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    onPressed: () => setState(() => _infoMessage = null),
                    child: Text(_infoMessageDismissLabel ?? "Ok"),
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
          child: Text("Jetzt ist der Kaufhansel abgestürzt."),
        );
    }
  }

  bool isLoading() {
    return _loading;
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
                  enabled: !isLoading(),
                  autofillHints: !isLoading() ? [AutofillHints.username] : null,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                  ),
                  validator: (address) {
                    if (!isValidEMailAddress(address)) {
                      return 'Gib eine gültige Email-Adresse ein';
                    }
                    return null;
                  },
                ),
                TextFormField(
                    controller: _passwordController,
                    enabled: !isLoading(),
                    autofillHints: !isLoading() ? [AutofillHints.password] : null,
                    decoration: const InputDecoration(
                      hintText: 'Kennwort',
                    ),
                    obscureText: true,
                    validator: (password) {
                      if (password.isEmpty) {
                        return 'Gib dein Kennwort richtig ein';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _login())
              ],
            ),
            Padding(
                padding: EdgeInsets.only(top: 15),
                child: ElevatedButton(child: Text("Anmelden"), onPressed: isLoading() ? null : _login)),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: OutlinedButton(
                  child: Text("Registrieren"),
                  onPressed: isLoading() ? null : () => setState(() => _pageMode = _PageMode.CHECK_INVITE)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: OutlinedButton(
                  child: Text("Kennwort vergessen"),
                  onPressed: isLoading() ? null : () => setState(() => _pageMode = _PageMode.RESET_PASSWORD_REQUEST)),
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
            enabled: !isLoading(),
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'Einladungs-Code'),
            onFieldSubmitted: (_) => _checkInviteCode(),
            validator: (code) {
              if (code.trim().isEmpty) {
                return 'Gib deinen Einladungs-Code ein';
              } else if (_inviteCodeInvalid) {
                return 'Der Code stimmt nicht';
              }
              return null;
            },
          ),
          Padding(
              padding: EdgeInsets.only(top: 15),
              child: ElevatedButton(child: Text("Weiter"), onPressed: isLoading() ? null : _checkInviteCode)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text("Zurück zur Anmeldung"),
                onPressed: isLoading() ? null : () => setState(() => _pageMode = _PageMode.LOGIN)),
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
      showErrorDialog(context, "Das hat nicht geklappt. Probier es später noch einmal.");
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
            enabled: !isLoading(),
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Nutzername'),
            validator: (userName) {
              if (userName.trim().isEmpty) {
                return 'Gib einen Nutzernamen ein';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _userEmailAddressController,
            enabled: !isLoading(),
            decoration: const InputDecoration(
              hintText: 'Email',
            ),
            validator: (address) {
              if (!isValidEMailAddress(address)) {
                return 'Gib eine gültige Email-Adresse ein';
              }
              if (_emailAddressInvalid) {
                return 'Nimm eine andere.';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _setPasswordController,
            enabled: !isLoading(),
            decoration: const InputDecoration(
              hintText: 'Kennwort',
            ),
            obscureText: true,
            validator: (password) {
              if (password.length < 8) {
                return 'Mindestens 8 Zeichen!';
              }
              if (_passwordInvalid) {
                return 'Denk dir was besseres aus.';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _confirmPasswordController,
            enabled: !isLoading(),
            decoration: const InputDecoration(
              hintText: 'Kennwort bestätigen',
            ),
            obscureText: true,
            validator: (password) {
              if (password.isEmpty || password != _setPasswordController.text) {
                return 'Gib dein Kennwort nochmal ein';
              }
              return null;
            },
            onFieldSubmitted: (_) => _registerFull(),
          ),
          Padding(
              padding: EdgeInsets.only(top: 15),
              child: ElevatedButton(child: Text("Registrieren"), onPressed: isLoading() ? null : _registerFull)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text("Zurück zur Anmeldung"),
                onPressed: isLoading() ? null : () => setState(() => _pageMode = _PageMode.LOGIN)),
          ),
        ],
      ),
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
            enabled: !isLoading(),
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Nutzername'),
            validator: (userName) {
              if (userName.trim().isEmpty) {
                return 'Gib einen Nutzernamen ein';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _setPasswordController,
            enabled: !isLoading(),
            decoration: const InputDecoration(
              hintText: 'Kennwort',
            ),
            obscureText: true,
            validator: (password) {
              if (password.length < 8) {
                return 'Mindestens 8 Zeichen!';
              }
              if (_passwordInvalid) {
                return 'Denk dir was besseres aus.';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _confirmPasswordController,
            enabled: !isLoading(),
            decoration: const InputDecoration(
              hintText: 'Kennwort bestätigen',
            ),
            obscureText: true,
            validator: (password) {
              if (password.isEmpty || password != _setPasswordController.text) {
                return 'Gib dein Kennwort nochmal ein';
              }
              return null;
            },
            onFieldSubmitted: (_) => _registerWithoutEmail(),
          ),
          Padding(
              padding: EdgeInsets.only(top: 15),
              child:
                  ElevatedButton(child: Text("Registrieren"), onPressed: isLoading() ? null : _registerWithoutEmail)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text("Zurück zur Anmeldung"),
                onPressed: isLoading() ? null : () => setState(() => _pageMode = _PageMode.LOGIN)),
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
            enabled: !isLoading(),
            decoration: const InputDecoration(hintText: 'Email-Adresse'),
            onFieldSubmitted: (_) => _requestPasswordReset(),
            validator: (emailAddress) {
              if (!isValidEMailAddress(emailAddress)) {
                return "Gib eine gültige Email-Adresse ein";
              }
              return null;
            },
          ),
          Padding(
              padding: EdgeInsets.only(top: 15),
              child: ElevatedButton(
                  child: Text("Kennwort zurücksetzen"), onPressed: isLoading() ? null : _requestPasswordReset)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text("Wiederherstellungs-Code eingeben"),
                onPressed: isLoading() ? null : () => setState(() => _pageMode = _PageMode.RESET_PASSWORD)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text("Zurück zur Anmeldung"),
                onPressed: isLoading() ? null : () => setState(() => _pageMode = _PageMode.LOGIN)),
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
      showErrorDialog(context, "Das hat nicht geklappt. Probier es später noch einmal.");
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
          Text(
              "Falls du beim Kaufhansel registriert bist, haben wir dir eine Email mit einem Wiederherstellungs-Code geschickt. "
              "Gib den Code hier ein, um dein Kennwort zurückzusetzen."),
          TextFormField(
            controller: _userEmailAddressController,
            enabled: !isLoading(),
            decoration: const InputDecoration(hintText: 'Email-Adresse'),
            onFieldSubmitted: (_) => _requestPasswordReset(),
            validator: (emailAddress) {
              if (!isValidEMailAddress(emailAddress)) {
                return "Gib eine gültige Email-Adresse ein";
              }
              return null;
            },
          ),
          TextFormField(
            controller: _resetPasswordCodeController,
            enabled: !isLoading(),
            decoration: const InputDecoration(hintText: 'Wiederherstellungs-Code'),
            onFieldSubmitted: (_) => _resetPassword(),
            validator: (code) {
              if (code.isEmpty) {
                return "Gib den Wiederherstellungs-Code ein";
              }
              return null;
            },
          ),
          TextFormField(
            controller: _setPasswordController,
            enabled: !isLoading(),
            decoration: const InputDecoration(
              hintText: 'Neues Kennwort',
            ),
            obscureText: true,
            validator: (password) {
              if (password.length < 8) {
                return 'Mindestens 8 Zeichen!';
              }
              if (_passwordInvalid) {
                return 'Denk dir was besseres aus.';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _confirmPasswordController,
            enabled: !isLoading(),
            decoration: const InputDecoration(
              hintText: 'Neues Kennwort bestätigen',
            ),
            obscureText: true,
            validator: (password) {
              if (password.isEmpty || password != _setPasswordController.text) {
                return 'Gib dein neues Kennwort nochmal ein';
              }
              return null;
            },
            onFieldSubmitted: (_) => _resetPassword(),
          ),
          Padding(
              padding: EdgeInsets.only(top: 15),
              child: ElevatedButton(child: Text("Kennwort ändern"), onPressed: isLoading() ? null : _resetPassword)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text("Zurück zur Anmeldung"),
                onPressed: isLoading() ? null : () => setState(() => _pageMode = _PageMode.LOGIN)),
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
      showErrorDialog(
          context,
          "Das hat nicht geklappt.\n\nStimmt die Email-Adresse?\nIst der Wiederherstellungs-Code richtig?"
          "\nHast du ein vernünftiges Passwort gewählt?\nDenk auch daran, dass der Wiederherstellungs-Code nur eine Stunde gültig ist.");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showPasswordResetSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Du hast dein Kennwort erfolgreich geändert."),
      duration: Duration(seconds: 5),
    ));
  }

  Widget _buildProgressBar(BuildContext context) {
    if (isLoading()) {
      return LinearProgressIndicator(minHeight: 5, backgroundColor: Theme.of(context).scaffoldBackgroundColor);
    } else {
      return SizedBox(height: 5);
    }
  }

  List<Widget> _buildBottomInfos(BuildContext context) {
    final zwoHanselLink = Link('https://zwohansel.de', text: "zwohansel.de");
    if (_frontendVersion == null) {
      return [zwoHanselLink];
    }
    if (_backendVersion != null && _backendVersion.isMoreRecentThan(_frontendVersion)) {
      return [
        Text(_frontendVersion.toString()),
        Link(_DownloadLink,
            text: "Version ${_backendVersion.toString()} ist verfügbar.",
            style: TextStyle(fontWeight: FontWeight.bold)),
        zwoHanselLink
      ];
    }
    return [Text(_frontendVersion.toString()), zwoHanselLink];
  }

  void _login() async {
    if (!_loginFormKey.currentState.validate()) {
      return;
    }
    setState(() => _loading = true);

    try {
      ShoppingListUserInfo userInfo =
          await RestClientWidget.of(context).login(_userEmailAddressController.text, _passwordController.text);
      if (userInfo != null) {
        widget._loggedIn(userInfo);
      } else {
        showErrorDialog(context, "Haben wir Deinen Account gelöscht oder hast Du Deine Zugangsdaten vergessen?");
      }
    } on SocketException catch (e) {
      if (e.osError.errorCode == 111 && Platform.isLinux || Platform.isAndroid) {
        showErrorDialog(
            context, "Haben wir den Server heruntergefahren oder bist du nicht mit dem Internet verbunden?");
      } else {
        showErrorDialog(context,
            "Haben wir einen Fehler eingebaut oder hast du etwas falsch gemacht?\nComputer sagt: " + e.osError.message);
      }
    } on TimeoutException {
      showErrorDialog(context,
          "Schläft der Server oder ist das Internet zu langsam?\nJedenfalls hat das alles viel zu lange gedauert.");
    } catch (e) {
      showErrorDialog(context,
          "Haben wir einen Fehler eingebaut oder hast du etwas falsch gemacht?\nComputer sagt: " + e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _fetchBackendInfo() async {
    try {
      final frontendVersion = await _getVersion();
      setState(() => _frontendVersion = frontendVersion);
      final backendInfo = await RestClientWidget.of(context).getBackendInfo();
      setState(() => _backendVersion = backendInfo.version);
      if (frontendVersion != null) {
        await checkCompatibility(frontendVersion, backendInfo.version);
      }
      if (backendInfo.message?.severity == InfoMessageSeverity.CRITICAL) {
        showConfirmDialog(
          context,
          backendInfo.message.message,
          title: "Wichtige Durchsage",
          confirmBtnLabel: backendInfo.message.dismissLabel ?? "Ok",
          hideCancelBtn: true,
          confirmBtnColor: Theme.of(context).primaryColor,
        );
      } else if (backendInfo.message?.severity == InfoMessageSeverity.INFO) {
        setState(() {
          _infoMessage = backendInfo.message?.message;
          _infoMessageDismissLabel = backendInfo.message.dismissLabel;
        });
      }
      setState(() => _loading = false);
    } on Exception catch (e) {
      log("Failed to fetch backend info.", error: e);
      await showErrorDialog(context,
          "Hast du kein Internet oder ist der Server nicht erreichbar?\nWir können es ja nochmal versuchen...");
      await Future.delayed(Duration(seconds: 5)); // Don't let the user DDOS the server
      _fetchBackendInfo();
    }
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

  Future<void> checkCompatibility(Version frontendVersion, Version backendVersion) async {
    if (frontendVersion == null) {
      return;
    }
    if (!backendVersion.isCompatibleTo(frontendVersion)) {
      showCustomErrorDialog(
          context,
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Du verwendest immer noch die Kaufhanselversion ${frontendVersion.toString()} ???\n\nDie ist doch schon viel zu alt."
                " Hol dir die neu viel bessere Version ${backendVersion.toString()} von",
                textAlign: TextAlign.center,
              ),
              Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Link(
                    _DownloadLink,
                    text: "zwohansel.de",
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ))
            ],
          ),
          closeLabel: "Mache ich sofort!");
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
        showErrorDialog(context,
            "Wollen wir nicht, dass du dich registrierst oder hast du etwas falsch gemacht?\nProbiere es einfach später nochmal.");
      }
    } on Exception catch (e) {
      log("Registration failed.", error: e);
      showErrorDialog(context, "Irgendetwas stimmt nicht. Probiere es einfach später nochmal.");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showFullRegistrationSuccessMessage(String emailAddress) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          "Wir haben dir eine E-Mail an $emailAddress geschickt... folge dem Aktivierungs-Link, dann kannst du dich anmelden."),
      duration: Duration(seconds: 15),
      action: SnackBarAction(
        label: "Mach ich",
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
        showErrorDialog(context,
            "Wollen wir nicht, dass du dich registrierst oder hast du etwas falsch gemacht?\nProbiere es einfach später nochmal.");
      }
    } on Exception catch (e) {
      log("Registration failed.", error: e);
      showErrorDialog(context, "Irgendetwas stimmt nicht. Probiere es einfach später nochmal.");
    } finally {
      setState(() => _loading = false);
    }
  }

  void showRegistrationWithoutEmailSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          "Deine Registrierung ist abgeschlossen. Du kannst dich nun mit deiner Email-Adresse und deinem Passwort anmelden."),
    ));
  }
}
