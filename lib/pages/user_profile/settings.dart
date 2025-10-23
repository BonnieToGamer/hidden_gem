import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/auth/authenticate.dart';
import 'package:hidden_gem/pages/auth/sign_in.dart';
import 'package:hidden_gem/pages/home_nav.dart';
import 'package:hidden_gem/pages/home_page.dart';
import 'package:hidden_gem/services/auth_service.dart';
import 'package:hidden_gem/services/geo_locator_service.dart';
import 'package:hidden_gem/services/image_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _passwordController;
  bool _isOldPasswordVisible = false;
  bool _isPasswordVisible = false;
  bool _updateEmail = false;
  bool _updatePassword = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _oldPasswordController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),

      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            child: SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _changeProfileSettings(),
                    _locationPermissionButton(),

                    ElevatedButton(
                      onPressed: () async {
                        await AuthService.signOut();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                Authenticate(forward: () => HomeNavigation()),
                          ),
                          (_) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red.shade900,
                      ),
                      child: Text("Sign Out"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _locationPermissionButton() {
    if (GeolocatorService.hasLocationPermission) {
      return SizedBox();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "You don't seem to have location permissions enabled, please enable them for the best experience",
          textAlign: TextAlign.center,
        ),
        ElevatedButton(
          onPressed: () async {
            bool result = await GeolocatorService.checkPermission();

            if (result == false) {
              GeolocatorService.openSettings();
            }

            setState(() {}); // update button
          },
          child: Text("Open Location settings"),
        ),
      ],
    );
  }

  Widget _changeProfileSettings() {
    final user = Provider.of<AuthState>(context, listen: false).user!;
    final showEmailPasswordFields = AuthService.isEmailAuthenticated();

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 128,
            height: 128,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: user.photoURL!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                  width: 128,
                  height: 128,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const SizedBox(
                  width: 128,
                  height: 128,
                  child: Center(child: Icon(Icons.error)),
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: _changeProfilePicture,
            label: Text("Change profile picture"),
          ),

          SizedBox(height: 20),

          if (showEmailPasswordFields) ...[
            TextFormField(
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: user.email ?? "Email",
              ),
              readOnly: true,
              controller: _emailController,
              validator: (String? text) {
                if (text == null || text.isEmpty) {
                  _updateEmail = false;
                  return null;
                }

                if (EmailValidator.validate(text) == false) {
                  return "Please enter a valid email";
                }

                _updateEmail = true;

                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Your current password",
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isOldPasswordVisible = !_isOldPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isOldPasswordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
              obscureText: _isOldPasswordVisible == false,
              enableSuggestions: false,
              autocorrect: false,
              controller: _oldPasswordController,
              validator: (String? text) {
                if (text == null || text.isEmpty) {
                  return "You need to enter your password";
                }

                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Password",
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
              obscureText: _isPasswordVisible == false,
              enableSuggestions: false,
              autocorrect: false,
              controller: _passwordController,
              validator: (String? text) {
                if (text == null || text.isEmpty) {
                  _updatePassword = false;
                  return null;
                }

                // regex taken from: https://regexpattern.com/strong-password/
                if (!RegExp(
                  r'^\S*(?=\S{6,})(?=\S*\d)(?=\S*[A-Z])(?=\S*[a-z])(?=\S*[!@#$%^&*? ])\S*$',
                ).hasMatch(text)) {
                  return """
Password must be:
 - Minimum 6 characters
 - At least 1 upper case English letter
 - At least 1 lower case English letter
 - At least 1 letter
 - At least 1 special character""";
                }

                _updatePassword = true;
                return null;
              },
            ),

            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(4),
                  ),
                ),
                onPressed: _updateProfile,
                child: const Text("Update profile"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _updateProfile() async {
    final user = Provider.of<AuthState>(context, listen: false).user!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_updatePassword) {
      final success = await AuthService.reAuthenticate(
        user.email!,
        _oldPasswordController.text,
      );

      if (success) {
        final result = await AuthService.updatePassword(
          _passwordController.text,
        );

        if (!mounted) return;

        if (result) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: const Text("Updated password")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text("Failed to update password")),
          );
        }
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text("Old password is incorrect")),
        );
      }
    }
  }

  Future<void> _changeProfilePicture() async {
    final user = Provider.of<AuthState>(context, listen: false).user!;
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    final id = await ImageService.uploadImage(file, "avatars");
    if (!mounted) return;
    if (id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: const Text("Could not upload image")));
      return;
    }

    final url = await ImageService.getImageUrl(id, "avatars");
    await user.updatePhotoURL(url);
    await AuthService.refreshUser();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Profile picture updated!")));

    setState(() {});
  }
}
