import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/auth/AuthAdapter.dart';
import 'package:mtaa_project/layout/ApplicationAppBar.dart';

class _AuthFormField {
  _AuthFormField(
      {required this.label, required this.onChanged, this.obscureText = false});

  final String label;
  final void Function(String) onChanged;
  final bool obscureText;
}

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

  final String title;
  final List<_AuthFormField> fields;
  final String submitLabel;
  final void Function() onSubmit;
  final String alternateText;
  final String alternateLabel;
  final void Function() onAlternate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: applicationAppBar(context, title),
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
                Text(alternateText),
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

  void _submit() {
    AuthAdapter.instance.setUser(User(email: _email));
    _router!.goNamed("Home");
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    return _AuthForm(
      title: "Login",
      fields: [
        _AuthFormField(label: "Email", onChanged: _setEmail),
        _AuthFormField(
            label: "Password", onChanged: _setPassword, obscureText: true),
      ],
      submitLabel: "Login",
      onSubmit: _submit,
      alternateText: "If you don't have an account you can ",
      alternateLabel: "Register Here",
      onAlternate: () => router.goNamed("Register"),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router = GoRouter.of(context);
  }
}

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

  void _submit() {
    AuthAdapter.instance.setUser(User(email: _email));
    _router!.goNamed("Home");
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    return _AuthForm(
      title: "Register",
      fields: [
        _AuthFormField(label: "Name", onChanged: _setName),
        _AuthFormField(label: "Email", onChanged: _setEmail),
        _AuthFormField(
            label: "Password", onChanged: _setPassword, obscureText: true),
        _AuthFormField(
            label: "Confirm Password",
            onChanged: _setConfirmPassword,
            obscureText: true),
      ],
      submitLabel: "Register",
      onSubmit: _submit,
      alternateText: "If you already have an account you can ",
      alternateLabel: "Login Here",
      onAlternate: () => router.goNamed("Login"),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router = GoRouter.of(context);
  }
}
