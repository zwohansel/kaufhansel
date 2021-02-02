import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/widgets/link.dart';
import 'package:package_info/package_info.dart';

import 'widgets/error_dialog.dart';

class LoginPage extends StatefulWidget {
  final void Function(ShoppingListUserInfo) _loggedIn;

  const LoginPage({@required void Function(ShoppingListUserInfo) loggedIn}) : _loggedIn = loggedIn;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userEmailAddressController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _setPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _registerMode = false;
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
        _loginFormKey.currentState.validate();
      }
    });
    _inviteCodeController.addListener(() {
      if (_inviteCodeInvalid) {
        setState(() => _inviteCodeInvalid = false);
        _loginFormKey.currentState.validate();
      }
    });
    _setPasswordController.addListener(() {
      if (_passwordInvalid) {
        setState(() => _passwordInvalid = false);
        _loginFormKey.currentState.validate();
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
              child: Form(
                  key: _loginFormKey,
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
                        ..._buildInputs(),
                        ..._buildButtons()
                      ],
                    ),
                  )))),
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

  List<Widget> _buildInputs() {
    if (_registerMode) {
      return [
        TextFormField(
          controller: _userNameController,
          enabled: !_loading,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Nutzername'),
          validator: (userName) {
            if (userName.trim().isEmpty) {
              return 'Gibstu Nutzernamen ein!?';
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
          validator: (emailAddress) {
            final address = emailAddress.trim();
            if (address.length < 5 || !address.contains('@') || !address.contains('.') || address.contains(' ')) {
              return 'Gibstu gültige Email ein!?';
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
              return 'Gibstu Kennwort nochmal ein!?';
            }
            return null;
          },
          onFieldSubmitted: (_) => _register(),
        ),
        TextFormField(
          controller: _inviteCodeController,
          decoration: const InputDecoration(
            hintText: 'Einladungs-Code',
          ),
          validator: (inviteCode) {
            if (inviteCode.isEmpty) {
              return 'Gibstu Einladungs-Code ein!?';
            }
            if (_inviteCodeInvalid) {
              return 'Der Einladungs-Code stimmt nicht!';
            }
            return null;
          },
        ),
      ];
    }

    // Login
    return [
      AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _userNameController,
              enabled: !_loading,
              autofillHints: [AutofillHints.username],
              decoration: const InputDecoration(
                hintText: 'Nutzername',
              ),
              validator: (userName) {
                if (userName.trim().isEmpty) {
                  return 'Gibstu Nutzernamen ein!?';
                }
                return null;
              },
            ),
            TextFormField(
                controller: _passwordController,
                enabled: !_loading,
                autofillHints: [AutofillHints.password],
                decoration: const InputDecoration(
                  hintText: 'Kennwort',
                ),
                obscureText: true,
                validator: (password) {
                  if (password.isEmpty) {
                    return 'Gibstu Kennwort ein!?';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _login())
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildButtons() {
    if (_registerMode) {
      return [
        Padding(
            padding: EdgeInsets.only(top: 15),
            child: ElevatedButton(child: Text("Registrieren"), onPressed: _loading ? null : _register)),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: OutlinedButton(
              child: Text("Zurück zur Anmeldung"),
              onPressed: _loading ? null : () => setState(() => _registerMode = false)),
        )
      ];
    }

    // Login:
    return [
      Padding(
          padding: EdgeInsets.only(top: 15),
          child: ElevatedButton(child: Text("Anmelden"), onPressed: _loading ? null : _login)),
      Padding(
        padding: EdgeInsets.only(top: 10),
        child: OutlinedButton(
            child: Text("Registrieren"), onPressed: _loading ? null : () => setState(() => _registerMode = true)),
      )
    ];
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
          await RestClientWidget.of(context).login(_userNameController.text, _passwordController.text);
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
      setState(() {
        _loading = false;
      });
    }
  }

  void _register() async {
    if (!_loginFormKey.currentState.validate()) {
      return;
    }
    setState(() => _loading = true);

    try {
      final registration = await RestClientWidget.of(context).register(_userNameController.text,
          _userEmailAddressController.text, _setPasswordController.text, _inviteCodeController.text);

      if (registration.isSuccess()) {
        setState(() => _registerMode = false);
        showRegistrationSuccessMessage(_userEmailAddressController.text);
        _userEmailAddressController.clear();
        _setPasswordController.clear();
        _confirmPasswordController.clear();
        _inviteCodeController.clear();
      } else if (registration.isInviteCodeInvalid()) {
        setState(() => _inviteCodeInvalid = true);
        _loginFormKey.currentState.validate();
      } else if (registration.isEMailAddressInvalid()) {
        setState(() => _emailAddressInvalid = true);
        _loginFormKey.currentState.validate();
      } else if (registration.isPasswordInvalid()) {
        setState(() => _passwordInvalid = true);
        _loginFormKey.currentState.validate();
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

  void showRegistrationSuccessMessage(String emailAddress) {
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
}
