import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/error_dialog.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:url_launcher/url_launcher.dart';

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
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (_loginFormKey.currentState.validate()) {
                                    if (await RestClientWidget.of(context)
                                        .login(_userNameController.text, _passwordController.text)) {
                                      widget._loggedIn();
                                    } else {
                                      showErrorDialog(context,
                                          "Haben wir Deinen Account gelöscht oder hast Du Deine Zugangsdaten vergessen?");
                                    }
                                  }
                                },
                                child: Text("Anmelden"))),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: OutlineButton(
                              child: Text("Registrieren"),
                              onPressed: () => showErrorDialog(
                                  context, "Die Registrierung zum Kaufhansel wird bald für Dich verfügbar sein!")),
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
}
