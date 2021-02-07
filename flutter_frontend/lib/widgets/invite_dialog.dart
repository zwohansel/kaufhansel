import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/widgets/error_dialog.dart';
import 'package:kaufhansel_client/widgets/link.dart';
import 'package:share/share.dart';

class InviteDialog extends StatefulWidget {
  final RestClient _client;

  const InviteDialog(this._client);

  @override
  _InviteDialogState createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteDialog> {
  bool _loading = true;
  String _code;

  @override
  void initState() {
    super.initState();
    _fetchInviteCode();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(title: _buildTitle(), children: [
      Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 12),
          child: _loading ? _buildGenerateCode() : _buildShowCode(context))
    ]);
  }

  Widget _buildTitle() {
    List<Widget> children = [Text("Einladungs-Code")];

    if (!_loading && (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia)) {
      children.add(IconButton(
          icon: Icon(Icons.share),
          onPressed: () => Share.share(_code,
              subject: "Werde mit diesem Code zum Kaufhansel! "
                  "Lade dir den Kaufhansel von https://zwohansel.de/kaufhansel/download runter.")));
    }

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }

  Center _buildGenerateCode() {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text("Code wird generiert..."),
          SizedBox(height: 20),
          Align(
              alignment: Alignment.bottomRight,
              child: OutlinedButton(child: Text("Schließen"), onPressed: () => Navigator.pop(context, false))),
        ],
      ),
    );
  }

  Column _buildShowCode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SelectableText(_code, style: Theme.of(context).textTheme.headline3),
        ),
        SizedBox(height: 20),
        Flexible(
            child: Text("Schicke anderen Hanseln diesen Code, damit sie sich beim Kaufhansel registrieren können.")),
        SizedBox(height: 20),
        Flexible(child: Text("Die Downloads gibts hier: ")),
        Flexible(child: Link("https://zwohansel.de/kaufhansel/download", selectable: true)),
        SizedBox(height: 20),
        Align(
            alignment: Alignment.bottomRight,
            child: OutlinedButton(child: Text("Schließen"), onPressed: () => Navigator.pop(context, false)))
      ],
    );
  }

  void _fetchInviteCode() async {
    try {
      final code = await widget._client.generateInviteCode();
      setState(() {
        _code = code;
        _loading = false;
      });
    } on Exception catch (e) {
      log("Failed to generate invite code", error: e);
      Navigator.pop(context);
      showErrorDialog(context, "Das hat nicht funtioniert. Probier es nochmal.");
    }
  }
}
