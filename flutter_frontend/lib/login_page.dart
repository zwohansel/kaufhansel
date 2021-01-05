import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();

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
                        TextFormField(
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
                                onPressed: () {
                                  if (_loginFormKey.currentState.validate()) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(title: Text("Erfolgreich."));
                                      },
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(title: Text("Nein!"));
                                      },
                                    );
                                  }
                                },
                                child: Text("Anmelden"))),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: OutlineButton(child: Text("Registrieren"), onPressed: () {}),
                        )
                      ],
                    ),
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
