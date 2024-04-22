import 'package:flutter/material.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/user/user_header.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

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

   Future<void> _changeProfilePicture() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image, // Limit to image files
        allowMultiple: false, // Allow only one image to be picked
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!); // Get the selected file
        // Use setState to update the UI or do something with the selected file
        setState(() {
          // For example, you could store the file path in your state
          // and display the image somewhere in your UI
          // _selectedImagePath = file.path;
        });
        // TODO: Implement the logic to upload the file to your server or storage
        print('Selected image path: ${file.path}');
      } else {
        // User canceled the picker
        print('No image selected');
      }
    } catch (e) {
      // Handle any exceptions here
      print('Error picking file: $e');
    }
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
