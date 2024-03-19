import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kaufhansel_client/generated/l10n.dart';

class CheckInviteCodeForm extends StatefulWidget {
  final Future<bool> Function(String) onInviteCode;
  final bool enabled;
  final List<Widget>? extraFormChildren;
  final String? initialCode;
  final bool? initialCodeIsInvalid;

  const CheckInviteCodeForm(
      {required this.onInviteCode, this.enabled = true, this.extraFormChildren, this.initialCode, this.initialCodeIsInvalid});

  @override
  _CheckInviteCodeFormState createState() => _CheckInviteCodeFormState();
}

class _CheckInviteCodeFormState extends State<CheckInviteCodeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _inviteCodeController;
  bool _inviteCodeInvalid = false;

  @override
  void initState() {
    super.initState();
    _inviteCodeController = TextEditingController();
    final initialCode = widget.initialCode;
    if (initialCode != null) {
      _inviteCodeInvalid = widget.initialCodeIsInvalid ?? false;
      _inviteCodeController.text = initialCode;
      // The form key has not current state yet.
      // The state is created after the first render therefore we postpone the validate call.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.validate();
      });
    }

    _inviteCodeController.addListener(() {
      if (_inviteCodeInvalid) {
        setState(() => _inviteCodeInvalid = false);
        _formKey.currentState?.validate();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _inviteCodeController,
            enabled: widget.enabled,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(hintText: AppLocalizations.of(context).invitationCodeHint),
            onFieldSubmitted: (_) => _checkInviteCode(),
            validator: (code) {
              if (code == null || code.trim().isEmpty) {
                return AppLocalizations.of(context).invitationCodeEmpty;
              } else if (_inviteCodeInvalid) {
                return AppLocalizations.of(context).invitationCodeInvalid;
              }
              return null;
            },
          ),
          SizedBox(height: 15),
          ElevatedButton(
              child: Text(AppLocalizations.of(context).buttonNext),
              onPressed: widget.enabled ? _checkInviteCode : null),
          ...(widget.extraFormChildren ?? []),
        ],
      ),
    );
  }

  void _checkInviteCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    bool valid = await widget.onInviteCode(_inviteCodeController.text);
    if (!valid) {
      setState(() {
        _inviteCodeInvalid = true;
      });
      _formKey.currentState?.validate();
    }
  }
}
