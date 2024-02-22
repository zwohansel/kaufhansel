import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/utils/input_validation.dart';

class EMailPasswordForm extends StatefulWidget {
  final void Function(String email, String password) onLogin;
  final void Function(String email)? onEmailChanged;
  final String? initialEmail;
  final bool enabled;
  final List<Widget>? extraFormChildren;

  const EMailPasswordForm(
      {required this.onLogin, this.onEmailChanged, this.initialEmail, this.enabled = true, this.extraFormChildren});

  @override
  _EMailPasswordFormState createState() => _EMailPasswordFormState();
}

class _EMailPasswordFormState extends State<EMailPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userEmailAddressController;
  late TextEditingController _passwordController;
  bool _emailAddressInvalid = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _userEmailAddressController = TextEditingController(text: widget.initialEmail);
    _userEmailAddressController.addListener(() {
      final onEmailChanged = widget.onEmailChanged;
      if (onEmailChanged != null) {
        onEmailChanged(_userEmailAddressController.text);
      }
      if (_emailAddressInvalid) {
        setState(() => _emailAddressInvalid = false);
        _formKey.currentState?.validate();
      }
    });

    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _userEmailAddressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmailField(context),
            _buildPasswordField(context),
            SizedBox(height: 15),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).buttonLogin),
              onPressed: widget.enabled ? _login : null,
            ),
            if (widget.extraFormChildren != null) ...(widget.extraFormChildren ?? []),
          ],
        ),
      ),
    );
  }

  TextFormField _buildEmailField(BuildContext context) {
    return TextFormField(
      controller: _userEmailAddressController,
      enabled: widget.enabled,
      autofillHints: widget.enabled ? [AutofillHints.username] : null,
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

  TextFormField _buildPasswordField(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      enabled: widget.enabled,
      autofillHints: widget.enabled ? [AutofillHints.password] : null,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: _obscurePassword ? Icon(Icons.remove_red_eye) : Icon(Icons.remove_red_eye_outlined),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        hintText: AppLocalizations.of(context).passwordHint,
      ),
      obscureText: _obscurePassword,
      validator: (password) {
        if (password == null || password.isEmpty) {
          return AppLocalizations.of(context).passwordEmpty;
        }
        return null;
      },
      onFieldSubmitted: (_) => _login(),
    );
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onLogin(_userEmailAddressController.text, _passwordController.text);
    }
  }
}
