import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/home_page.dart';
import 'package:hidden_gem/services/google_auth_service.dart';

// A stateless widget for the Sign-In screen
class SignInScreen extends StatelessWidget {
  // Instance of GoogleAuthService to handle Google Sign-In
  final GoogleAuthService _authService = GoogleAuthService();

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with title and styling
      appBar: AppBar(
        title: Text("Sign In"),
      ),
      // Main body of the screen
      body: Center(
        // ElevatedButton for Google Sign-In
        child: ElevatedButton(
          // Asynchronous function triggered on button press
          onPressed: () async {
            // Attempt to sign in with Google
            User? user = await _authService.signInWithGoogle();
            // If sign-in is successful, navigate to the HomeScreen
            if (user != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage(user: user)),
              );
            }
          },
          // Text displayed on the button
          child: Text("Sign in with Google"),
        ),
      ),
    );
  }
}