import 'package:flutter/material.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/widgets/error_dialog.dart';
import 'package:kaufhansel_client/widgets/link.dart';

import '../widgets/title_widget.dart';

class AppSettings extends StatefulWidget {
  final ShoppingListUserInfo _userInfo;
  final void Function() _onLogOut;

  AppSettings({@required ShoppingListUserInfo userInfo, @required void Function() onLogOut})
      : _userInfo = userInfo,
        _onLogOut = onLogOut;

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => !_loading,
        child: Scaffold(
            appBar: AppBar(
              title: TitleWidget(),
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
                                          Text("${widget._userInfo.username}, was willst du ändern?",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5
                                                  .apply(fontFamilyFallback: ['NotoColorEmoji'])),
                                          SizedBox(height: 12),
                                          Text("Deine Email-Adresse: ${widget._userInfo.emailAddress}"),
                                          SizedBox(height: 24),
                                          OutlinedButton(
                                            child: Text("Ich will mich mal kurz abmelden"),
                                            style: OutlinedButton.styleFrom(primary: Colors.red),
                                            onPressed: _onLogOut,
                                          ),
                                          SizedBox(height: 12),
                                          OutlinedButton(
                                            child: Text("Ich will mein Benutzerkonto löschen..."),
                                            style: OutlinedButton.styleFrom(primary: Colors.red),
                                            onPressed: () =>
                                                showErrorDialog(context, "Schade, aber das geht hier noch nicht."),
                                          )
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
                                          Text("Über den Kaufhansel",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5
                                                  .apply(fontFamilyFallback: ['NotoColorEmoji'])),
                                          SizedBox(height: 12),
                                          Text("Der Kaufhansel ist noch beta: Version 0.0.2"),
                                          SizedBox(height: 12),
                                          Link('https://zwohansel.de',
                                              text: "Mehr über die Entwickler auf zwohansel.de"),
                                          SizedBox(height: 12),
                                          Link('https://github.com/zwohansel', text: "ZwoHansel auf GitHub"),
                                          SizedBox(height: 12),
                                          Link('https://github.com/zwohansel/kaufhansel',
                                              text: "Der Kaufhansel auf GitHub"),
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
    Navigator.pop(context);
    widget._onLogOut();
  }

  Widget _buildProgressBar() {
    if (_loading) {
      return LinearProgressIndicator(
        minHeight: 5,
      );
    } else {
      return Container();
    }
  }
}
