import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/layout/application_app_bar.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';

/// Field definition for [_AuthForm]
class _AuthFormField {
  _AuthFormField(
      {required this.label, required this.onChanged, this.obscureText = false});

  /// Title to display above this field
  final String label;

  /// Callback after user has edited this value
  final void Function(String) onChanged;

  /// Should the value of this field be unreadable like a password field
  final bool obscureText;
}

/// Template for building login and register pages
class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.title,
    required this.fields,
    required this.submitLabel,
    required this.onSubmit,
    required this.alternateText,
    required this.alternateLabel,
    required this.onAlternate,
  });

  /// Title to display in app bar
  final String title;

  /// List of fields to display
  final List<_AuthFormField> fields;

  /// What label should the submit button have
  final String submitLabel;

  /// Callback after submit button clicked
  final void Function() onSubmit;
  final String alternateText;
  final String alternateLabel;
  final void Function() onAlternate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ApplicationAppBar(
          title: title,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ...fields.map(
              (field) => TextField(
                onChanged: field.onChanged,
                decoration: InputDecoration(
                  label: Text(field.label),
                ),
                obscureText: field.obscureText,
              ),
            ),
            const SizedBox(height: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FilledButton(onPressed: onSubmit, child: Text(submitLabel))
              ],
            ),
            Row(
              children: [
                Text("$alternateText "),
                TextButton(
                  onPressed: onAlternate,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                  ),
                  child: Text(alternateLabel),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// Page for the user to log in
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GoRouter? _router;

  String _email = "";
  String _password = "";

  void _setEmail(String email) => setState(() => _email = email);
  void _setPassword(String password) => setState(() => _password = password);

  void _submit() async {
    try {
      await AuthAdapter.instance.login(_email, _password);
    } on UserException catch (error) {
      if (!mounted) return;
      alertError(context, "Login", error);
      return;
    }

    _router!.goNamed("Home");
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    return ListenableBuilder(
      listenable: LanguageManager.instance,
      builder: (_, __) => _AuthForm(
        title: LanguageManager.instance.language.login(),
        fields: [
          _AuthFormField(
            label: LanguageManager.instance.language.email(),
            onChanged: _setEmail,
          ),
          _AuthFormField(
            label: LanguageManager.instance.language.password(),
            onChanged: _setPassword,
            obscureText: true,
          ),
        ],
        submitLabel: LanguageManager.instance.language.loginAction(),
        onSubmit: _submit,
        alternateText:
            LanguageManager.instance.language.ifYouDontHaveAnAccount(),
        alternateLabel: LanguageManager.instance.language.registerHere(),
        onAlternate: () => router.goNamed("Register"),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router = GoRouter.of(context);
  }
}

/// Page for the user to register
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  GoRouter? _router;

  String _name = "";
  String _email = "";
  String _password = "";
  String _confirmPassword = "";

  void _setName(String name) => setState(() => _name = name);
  void _setEmail(String email) => setState(() => _email = email);
  void _setPassword(String password) => setState(() => _password = password);
  void _setConfirmPassword(String confirmPassword) =>
      setState(() => _confirmPassword = confirmPassword);

  void _submit() async {
    if (_password != _confirmPassword) return;

    try {
      await AuthAdapter.instance.register(_name, _email, _password);
    } on UserException catch (error) {
      if (!mounted) return;
      alertError(context, "Register", error);
      return;
    }

    _router!.goNamed("Home");
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    return ListenableBuilder(
      listenable: LanguageManager.instance,
      builder: (_, __) => _AuthForm(
        title: LanguageManager.instance.language.register(),
        fields: [
          _AuthFormField(
            label: LanguageManager.instance.language.name(),
            onChanged: _setName,
          ),
          _AuthFormField(
            label: LanguageManager.instance.language.email(),
            onChanged: _setEmail,
          ),
          _AuthFormField(
            label: LanguageManager.instance.language.password(),
            onChanged: _setPassword,
            obscureText: true,
          ),
          _AuthFormField(
            label: LanguageManager.instance.language.confirmPassword(),
            onChanged: _setConfirmPassword,
            obscureText: true,
          ),
        ],
        submitLabel: LanguageManager.instance.language.registerAction(),
        onSubmit: _submit,
        alternateText:
            LanguageManager.instance.language.ifYouAlreadyHaveAnAccount(),
        alternateLabel: LanguageManager.instance.language.loginHere(),
        onAlternate: () => router.goNamed("Login"),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router = GoRouter.of(context);
  }
}
