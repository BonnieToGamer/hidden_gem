import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/sign_in_screen.dart';
import 'package:hidden_gem/services/google_auth_service.dart';

class HomePage extends StatelessWidget {
  final User user;
  final GoogleAuthService _authService = GoogleAuthService();

  HomePage({super.key, required this.user});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // Display user's name in the app bar
            "Welcome ${user.displayName}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.center,
          crossAxisAlignment:CrossAxisAlignment.center,
          children: [
            CircleAvatar(

              // Display user's profile picture
              backgroundImage: NetworkImage(user.photoURL ?? ""),

              // Set the radius of the avatar
              radius: 40,
            ),

            // Display user's email
            Text("Email: ${user.email}"),

            // Add spacing between elements
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {

                // Sign out from Google and Firebase
                _authService.signOut();

                // Navigate back to the sign-in screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => SignInScreen()),
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
    );
  }
}