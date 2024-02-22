import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/utils/input_validation.dart';

class ChangePasswordForm extends StatefulWidget {
  final void Function(String email, String changePasswordCode, String newPassword) onResetPassword;
  final String? initialEmail;
  final bool enabled;
  final List<Widget>? extraFormChildren;

  const ChangePasswordForm({
    required this.onResetPassword,
    this.initialEmail,
    this.enabled = true,
    this.extraFormChildren,
  });

  @override
  _ResetPasswordFormState createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userEmailAddressController;
  late TextEditingController _resetPasswordCodeController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _userEmailAddressController = TextEditingController(text: widget.initialEmail);
    _resetPasswordCodeController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();
  }

  @override
  void dispose() {
    _userEmailAddressController.dispose();
    _resetPasswordCodeController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
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
          SizedBox(height: 20),
          Text(AppLocalizations.of(context).passwordResetInfo),
          _buildEmailField(context),
          _buildResetPasswordCodeField(context),
          _buildPasswordField(context),
          _buildPasswordConfirmField(context),
          SizedBox(height: 15),
          ElevatedButton(
            child: Text(AppLocalizations.of(context).buttonPasswordChange),
            onPressed: widget.enabled ? _resetPassword : null,
          ),
          if (widget.extraFormChildren != null) ...(widget.extraFormChildren ?? []),
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

  TextFormField _buildResetPasswordCodeField(BuildContext context) {
    return TextFormField(
      controller: _resetPasswordCodeController,
      enabled: widget.enabled,
      decoration: InputDecoration(hintText: AppLocalizations.of(context).passwordResetCodeHint),
      validator: (code) {
        if (code == null || code.isEmpty) {
          return AppLocalizations.of(context).passwordResetCodeInvalid;
        }
        return null;
      },
    );
  }

  TextFormField _buildPasswordField(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      enabled: widget.enabled,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: _obscurePassword ? Icon(Icons.remove_red_eye) : Icon(Icons.remove_red_eye_outlined),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        hintText: AppLocalizations.of(context).passwordNewHint,
      ),
      obscureText: _obscurePassword,
      validator: (password) {
        if (password == null || password.length < 8) {
          return AppLocalizations.of(context).passwordToShort;
        }
        return null;
      },
    );
  }

  TextFormField _buildPasswordConfirmField(BuildContext context) {
    return TextFormField(
      controller: _passwordConfirmController,
      enabled: widget.enabled,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).passwordNewConfirmationHint,
      ),
      obscureText: _obscurePassword,
      validator: (password) {
        if (password == null || password.isEmpty || password != _passwordController.text) {
          return AppLocalizations.of(context).passwordNewConfirmationInvalid;
        }
        return null;
      },
      onFieldSubmitted: (_) => _resetPassword(),
    );
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onResetPassword(
          _userEmailAddressController.text, _resetPasswordCodeController.text, _passwordController.text);
    }
  }
}
