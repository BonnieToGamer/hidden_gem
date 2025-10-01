import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/home_page.dart';
import 'package:hidden_gem/services/auth_service.dart';
import 'package:hidden_gem/services/google_auth_service.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In")),
      body: Center(
        child: Column(
          children: [buildNormalSignIn(context), buildGoogleSignIn(context)],
        ),
      ),
    );
  }

  ElevatedButton buildGoogleSignIn(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        User? user = await GoogleAuthService.signInWithGoogle();
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage(user: user)),
          );
        }
      },
      child: Text("Sign in with Google"),
    );
  }

  buildNormalSignIn(BuildContext context) {}
}
