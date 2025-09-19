import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/sign_in_screen.dart';
import 'package:hidden_gem/services/google_auth_service.dart';
import 'package:hidden_gem/widgets/navigation_bar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final GoogleAuthService _authService = GoogleAuthService();

  HomePage({super.key});


  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();

    return Scaffold(
      body: Center(
        child: Text("Hello world!")
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 0),
    );
  }
}