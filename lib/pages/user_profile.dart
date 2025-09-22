import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/sign_in_screen.dart';
import 'package:hidden_gem/services/google_auth_service.dart';
import 'package:hidden_gem/widgets/navigation_bar.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatelessWidget {
  final GoogleAuthService _authService = GoogleAuthService();
  final User user;

  UserProfile({super.key, required this.user});

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
              backgroundImage: NetworkImage(user.photoURL ?? ""),
              radius: 40,
            ),
            Text("Email: ${user.email}"),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                _authService.signOut();

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
      bottomNavigationBar: CustomNavigationBar(currentIndex: 2, user: user),
    );
  }
}