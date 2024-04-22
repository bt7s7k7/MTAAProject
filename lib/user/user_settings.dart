import 'package:flutter/material.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/user/user_header.dart';

class UserSettings extends StatefulWidget {
  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement the password change logic here
      print('Password change requested');
    }
  }

  void _changeProfilePicture() {
    // TODO: Implement the profile picture change logic
    // This might involve showing a modal or another screen where the user can select an image
    print('Profile picture change requested');
  }


  @override
  Widget build(BuildContext context) {
    // Get the instance of your language manager
    final languageProfile = LanguageManager.instance.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProfile.accountSettings()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          UserHeader(user: AuthAdapter.instance.user!),
          ListTile(
            leading: Icon(Icons.photo_camera), // An icon for changing the picture
            title: Text(languageProfile.changeProfilePicture()), // Add this to your language profile
            onTap: _changeProfilePicture,
          ),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageProfile.changePassword(), // Add this method to your LanguageProfile
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: languageProfile.password(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    // Add your validation logic here
                    return null;
                  },
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: languageProfile.confirmPassword(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    // Add your validation logic here
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ElevatedButton(
                    onPressed: _changePassword,
                    child: Text(languageProfile.saveChanges()), // Add this method to your LanguageProfile
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 36),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
