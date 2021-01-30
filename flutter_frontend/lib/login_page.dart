import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/error_dialog.dart';

class LoginPage extends StatefulWidget {
  final void Function() _loggedIn;

  const LoginPage({@required void Function() loggedIn}) : _loggedIn = loggedIn;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  var _loading = false;

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
                    child: AutofillGroup(
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
                        TextFormField(
                          controller: _userNameController,
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
                          onFieldSubmitted: (_) => _buildLoginFunction(context)?.call(),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: ElevatedButton(child: Text("Anmelden"), onPressed: _buildLoginFunction(context))),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child:
                              OutlinedButton(child: Text("Registrieren"), onPressed: _buildRegisterFunction(context)),
                        )
                      ],
                    )),
                  )))),
      bottomNavigationBar: SizedBox(
          height: 60,
          child: Align(
              alignment: Alignment.center,
              child: InkWell(
                child: Text(
                  'zwohansel.de',
                  style: Theme.of(context).textTheme.subtitle2.apply(decoration: TextDecoration.underline),
                ),
                onTap: () => launch('https://zwohansel.de'),
              ))),
    );
  }

  Function _buildLoginFunction(BuildContext context) {
    if (_loading) {
      return null;
    } else {
      return () {
        if (_loginFormKey.currentState.validate()) {
          setState(() {
            _loading = true;
          });
          _login(context);
        }
      };
    }
  }

  void _login(BuildContext context) async {
    try {
      if (await RestClientWidget.of(context).login(_userNameController.text, _passwordController.text)) {
        widget._loggedIn();
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

  Function _buildRegisterFunction(BuildContext context) {
    if (_loading) {
      return null;
    } else {
      return () => showErrorDialog(context, "Die Registrierung zum Kaufhansel wird bald für Dich verfügbar sein!");
    }
  }

  Widget _buildProgressBar(BuildContext context) {
    if (_loading) {
      return LinearProgressIndicator(minHeight: 5, backgroundColor: Theme.of(context).scaffoldBackgroundColor);
    } else {
      return SizedBox(height: 5);
    }
  }
}
