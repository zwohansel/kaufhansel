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
import 'package:kaufhansel_client/widgets/link.dart';
import 'package:package_info/package_info.dart';

import 'widgets/error_dialog.dart';

class LoginPage extends StatefulWidget {
  final void Function(ShoppingListUserInfo) _loggedIn;

  const LoginPage({@required void Function(ShoppingListUserInfo) loggedIn}) : _loggedIn = loggedIn;

  @override
  _LoginPageState createState() => _LoginPageState();
}

enum _PageMode { LOGIN, CHECK_INVITE, REGISTRATION_FULL, REGISTRATION_WITHOUT_EMAIL }

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final _checkInviteCodeFormKey = GlobalKey<FormState>();
  final _registerFullFormKey = GlobalKey<FormState>();
  final _registerWithoutEmailFormKey = GlobalKey<FormState>();

  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _userEmailAddressController = TextEditingController();
  final _setPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _PageMode _pageMode = _PageMode.LOGIN;

  bool _loading = false;
  bool _inviteCodeInvalid = false;
  bool _emailAddressInvalid = false;
  bool _passwordInvalid = false;
  String _version;

  @override
  void initState() {
    super.initState();
    _setVersion();
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

  void _setVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _version = info.version);
    } on Exception catch (e) {
      log("Could not get app version.", error: e);
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    _inviteCodeController.dispose();
    _userEmailAddressController.dispose();
    _setPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                  child: SingleChildScrollView(child: _buildForm()),
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
      default:
        return Container();
    }
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
                  enabled: !_loading,
                  autofillHints: !_loading ? [AutofillHints.username] : null,
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
                    enabled: !_loading,
                    autofillHints: !_loading ? [AutofillHints.password] : null,
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
                child: ElevatedButton(child: Text("Anmelden"), onPressed: _loading ? null : _login)),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: OutlinedButton(
                  child: Text("Registrieren"),
                  onPressed: _loading ? null : () => setState(() => _pageMode = _PageMode.CHECK_INVITE)),
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
            enabled: !_loading,
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
              child: ElevatedButton(child: Text("Weiter"), onPressed: _loading ? null : _checkInviteCode)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text("Zurück zur Anmeldung"),
                onPressed: _loading ? null : () => setState(() => _pageMode = _PageMode.LOGIN)),
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
            enabled: !_loading,
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
            enabled: !_loading,
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
            enabled: !_loading,
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
            enabled: !_loading,
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
              child: ElevatedButton(child: Text("Registrieren"), onPressed: _loading ? null : _registerFull)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text("Zurück zur Anmeldung"),
                onPressed: _loading ? null : () => setState(() => _pageMode = _PageMode.LOGIN)),
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
            enabled: !_loading,
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
            enabled: !_loading,
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
            enabled: !_loading,
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
              child: ElevatedButton(child: Text("Registrieren"), onPressed: _loading ? null : _registerWithoutEmail)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: OutlinedButton(
                child: Text("Zurück zur Anmeldung"),
                onPressed: _loading ? null : () => setState(() => _pageMode = _PageMode.LOGIN)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    if (_loading) {
      return LinearProgressIndicator(minHeight: 5, backgroundColor: Theme.of(context).scaffoldBackgroundColor);
    } else {
      return SizedBox(height: 5);
    }
  }

  List<Widget> _buildBottomInfos(BuildContext context) {
    final zwoHanselLink = Link('https://zwohansel.de', text: "zwohansel.de");
    if (_version == null) {
      return [zwoHanselLink];
    }
    return [Text(_version), zwoHanselLink];
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
      duration: Duration(days: 1),
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
