import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:mtaa_project/user/user_header.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  void _changeName() async {
    if (_nameController.text == "") return;

    await AuthAdapter.instance.updateUser({
      "fullName": _nameController.text,
    });

    if (!mounted) return;
    popupResult(context, LanguageManager.instance.language.changesSaved());
  }

  void _changePassword() async {
    if (_passwordController.text != _confirmPasswordController.text ||
        _passwordController.text == "") return;

    await AuthAdapter.instance.updateUser({
      "password": _passwordController.text,
    });

    if (!mounted) return;
    popupResult(context, LanguageManager.instance.language.changesSaved());
  }

  Future<void> _changeProfilePicture() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    var file = result.files.first;

    await AuthAdapter.instance.updateIcon(file);

    if (!mounted) return;
    popupResult(context, LanguageManager.instance.language.changesSaved());
  }

  @override
  Widget build(BuildContext context) {
    // Get the instance of your language manager
    final languageProfile = LanguageManager.instance.language;

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        ListenableBuilder(
          listenable: LanguageManager.instance,
          builder: (_, __) => TitleMarker(
            title: LanguageManager.instance.language.accountSettings(),
          ),
        ),
        ListenableBuilder(
          listenable: AuthAdapter.instance,
          builder: (_, __) => UserHeader(user: AuthAdapter.instance.user!),
        ),
        ListTile(
          leading: const Icon(Icons.photo_camera),
          title: Text(languageProfile.changeProfilePicture()),
          onTap: _changeProfilePicture,
        ),
        Form(
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: languageProfile.name(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FilledButton(
                    onPressed: _changeName,
                    child: Text(languageProfile.saveChanges()),
                  ),
                ],
              ),
            ],
          ),
        ),
        Form(
          child: Column(
            children: [
              Text(
                languageProfile.changePassword(),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: languageProfile.password(),
                ),
                obscureText: true,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: languageProfile.confirmPassword(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FilledButton(
                    onPressed: _changePassword,
                    child: Text(languageProfile.saveChanges()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
