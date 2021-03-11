import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/utils/input_validation.dart';

class RequestPasswordResetForm extends StatefulWidget {
  final void Function(String email) onRequestPasswordReset;
  final String initialEmail;
  final bool enabled;
  final List<Widget> extraFormChildren;

  const RequestPasswordResetForm({
    @required this.onRequestPasswordReset,
    this.initialEmail,
    this.enabled = true,
    this.extraFormChildren,
  });

  @override
  _RequestPasswordResetFormState createState() => _RequestPasswordResetFormState();
}

class _RequestPasswordResetFormState extends State<RequestPasswordResetForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userEmailAddressController;

  @override
  void initState() {
    super.initState();
    _userEmailAddressController = TextEditingController();
  }

  @override
  void dispose() {
    _userEmailAddressController.dispose();
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
          _buildEmailField(context),
          SizedBox(height: 15),
          ElevatedButton(
            child: Text(AppLocalizations.of(context).buttonPasswordReset),
            onPressed: widget.enabled ? _requestPasswordReset : null,
          ),
          if (widget.extraFormChildren != null) ...widget.extraFormChildren,
        ],
      ),
    );
  }

  TextFormField _buildEmailField(BuildContext context) {
    return TextFormField(
      controller: _userEmailAddressController,
      enabled: widget.enabled,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).emailHint,
      ),
      validator: (address) {
        if (!isValidEMailAddress(address)) {
          return AppLocalizations.of(context).emailInvalid;
        }
        return null;
      },
    );
  }

  void _requestPasswordReset() {
    if (_formKey.currentState.validate()) {
      widget.onRequestPasswordReset(_userEmailAddressController.text);
    }
  }
}
