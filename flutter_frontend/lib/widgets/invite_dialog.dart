import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
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
  String? _code;

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
    List<Widget> children = [Text(AppLocalizations.of(context).invitationCodeHint)];

    if (!_loading && (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia)) {
      children.add(IconButton(
          icon: Icon(Icons.share),
          onPressed: () => Share.share(_code ?? "",
              subject: AppLocalizations.of(context).invitationCodeShareMessage))); //TODO: do not embed link in message
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
          Text(AppLocalizations.of(context).invitationCodeGenerating),
          SizedBox(height: 20),
          Align(
              alignment: Alignment.bottomRight,
              child: OutlinedButton(
                  child: Text(AppLocalizations.of(context).close), onPressed: () => Navigator.pop(context, false))),
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
          child: SelectableText(_code ?? "", style: Theme.of(context).textTheme.displaySmall),
        ),
        SizedBox(height: 20),
        Flexible(child: Text(AppLocalizations.of(context).invitationCodeRequestDistributionMessage)),
        SizedBox(height: 20),
        Flexible(child: Text(AppLocalizations.of(context).downloadLinkPromotion)),
        Flexible(child: Link(AppLocalizations.of(context).downloadLink, selectable: true)),
        SizedBox(height: 20),
        Align(
            alignment: Alignment.bottomRight,
            child: OutlinedButton(
                child: Text(AppLocalizations.of(context).close), onPressed: () => Navigator.pop(context, false)))
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
      log("Could not generate invite code", error: e);
      Navigator.pop(context);
      showErrorDialogForException(context, e, altText: AppLocalizations.of(context).exceptionGeneralTryAgainLater);
    }
  }
}
