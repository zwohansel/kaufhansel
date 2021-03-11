import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/model.dart';
import 'package:kaufhansel_client/utils/input_validation.dart';
import 'package:kaufhansel_client/widgets/error_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationForm extends StatefulWidget {
  final Future<RegistrationResult> Function({String email, @required String password, @required String userName})
      onRegister;
  final bool requireEmail;
  final void Function(String email) onEmailChanged;
  final String initialEmail;
  final bool enabled;
  final List<Widget> extraFormChildren;

  const RegistrationForm({
    @required this.onRegister,
    @required this.requireEmail,
    this.onEmailChanged,
    this.initialEmail,
    this.enabled = true,
    this.extraFormChildren,
  });

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userNameController;
  TextEditingController _userEmailAddressController;
  TextEditingController _passwordController;
  TextEditingController _passwordConfirmController;
  TapGestureRecognizer _tapRecognizer;
  bool _emailAddressInvalid = false;
  bool _passwordInvalid = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _userNameController = TextEditingController();

    _userEmailAddressController = TextEditingController(text: widget.initialEmail);
    _userEmailAddressController.addListener(() {
      widget?.onEmailChanged(_userEmailAddressController.text);
      if (_emailAddressInvalid) {
        setState(() => _emailAddressInvalid = false);
        _formKey.currentState?.validate();
      }
    });

    final passwordChangeListener = () {
      if (_passwordInvalid) {
        setState(() => _passwordInvalid = false);
        _formKey.currentState?.validate();
      }
    };

    _passwordController = TextEditingController();
    _passwordController.addListener(passwordChangeListener);

    _passwordConfirmController = TextEditingController();
    _passwordConfirmController.addListener(passwordChangeListener);

    _tapRecognizer = TapGestureRecognizer();
  }

  @override
  void dispose() {
    _userEmailAddressController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _tapRecognizer.dispose();
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
          _buildUserNameField(context),
          if (widget.requireEmail) _buildEmailField(context),
          _buildPasswordField(context),
          _buildPasswordConfirmField(context),
          SizedBox(
            height: 10,
          ),
          _buildConsentCheckBox(),
          SizedBox(height: 15),
          ElevatedButton(
              child: Text(AppLocalizations.of(context).buttonRegister), onPressed: widget.enabled ? _register : null),
          if (widget.extraFormChildren != null) ...widget.extraFormChildren,
        ],
      ),
    );
  }

  TextFormField _buildUserNameField(BuildContext context) {
    return TextFormField(
      controller: _userNameController,
      enabled: widget.enabled,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(hintText: AppLocalizations.of(context).userNameHint),
      validator: (userName) {
        if (userName.trim().isEmpty) {
          return AppLocalizations.of(context).userNameInvalid;
        }
        return null;
      },
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
        if (_emailAddressInvalid) {
          return AppLocalizations.of(context).emailAlreadyInUse;
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
        hintText: AppLocalizations.of(context).passwordHint,
      ),
      obscureText: _obscurePassword,
      validator: (password) {
        if (password.length < 8) {
          return AppLocalizations.of(context).passwordToShort;
        }
        if (_passwordInvalid) {
          return AppLocalizations.of(context).passwordInvalid;
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
        hintText: AppLocalizations.of(context).passwordConfirmationHint,
      ),
      obscureText: _obscurePassword,
      validator: (password) {
        if (password.isEmpty || password != _passwordController.text) {
          return AppLocalizations.of(context).passwordConfirmationInvalid;
        }
        return null;
      },
      onFieldSubmitted: (_) => _register(),
    );
  }

  FormField<bool> _buildConsentCheckBox() {
    return FormField<bool>(
      validator: (checked) {
        if (!checked) {
          return "";
        }
        return null;
      },
      initialValue: false,
      builder: (FormFieldState<bool> state) {
        final textStyle =
            state.hasError ? TextStyle(color: Theme.of(context).errorColor) : Theme.of(context).textTheme.bodyText1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: state.value,
              onChanged: state.didChange,
              visualDensity: VisualDensity.compact,
            ),
            SizedBox(width: 10),
            Flexible(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: AppLocalizations.of(context).registrationConsentFirstPart, style: textStyle),
                    TextSpan(
                        text: AppLocalizations.of(context).privacyPolicy,
                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        recognizer: _tapRecognizer
                          ..onTap = () => launch(AppLocalizations.of(context).privacyPolicyLink)),
                    TextSpan(text: AppLocalizations.of(context).registrationConsentMiddlePart, style: textStyle),
                    TextSpan(
                        text: AppLocalizations.of(context).disclaimer,
                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        recognizer: _tapRecognizer..onTap = () => launch(AppLocalizations.of(context).disclaimerLink)),
                    TextSpan(text: AppLocalizations.of(context).registrationConsentLastPart, style: textStyle),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _register() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    final result = await widget.onRegister(
      email: widget.requireEmail ? _userEmailAddressController.text : null,
      password: _passwordController.text,
      userName: _userNameController.text,
    );

    if (result.isSuccess()) {
      if (widget.requireEmail) {
        _showFullRegistrationSuccessMessage(_userEmailAddressController.text);
      } else {
        _showRegistrationWithoutEmailSuccessMessage();
      }
    } else if (result.isEMailAddressInvalid()) {
      setState(() => _emailAddressInvalid = true);
      _formKey.currentState.validate();
    } else if (result.isPasswordInvalid()) {
      setState(() => _passwordInvalid = true);
      _formKey.currentState.validate();
    } else if (result.isUnknownFailure()) {
      showErrorDialog(context, AppLocalizations.of(context).exceptionRegistrationFailedTryAgainLater);
    }
  }

  void _showFullRegistrationSuccessMessage(String emailAddress) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context).activationLinkSent(emailAddress)),
      duration: Duration(seconds: 15),
      action: SnackBarAction(
        label: AppLocalizations.of(context).ok,
        onPressed: () => ScaffoldMessenger.of(context).removeCurrentSnackBar(),
      ),
    ));
  }

  void _showRegistrationWithoutEmailSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context).registrationSuccessful),
    ));
  }
}
