import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/sign_in.dart';
import 'package:hidden_gem/services/auth_service.dart';

class Authenticate extends StatelessWidget {
  final Widget Function(User) forward;

  const Authenticate({
    super.key,
    required this.forward
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: AuthService.userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final user = snapshot.data!;
            return forward(user);
          }

          return SignIn();
        }
    );
  }
}