import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/sign_in_screen.dart';
import 'package:hidden_gem/services/google_auth_service.dart';

class Settings extends StatelessWidget {
  Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),

      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await GoogleAuthService.signOut();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => SignInScreen()),
              (_) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red.shade900,
          ),
          child: Text("Sign Out"),
        ),
      ),
    );
  }
}
