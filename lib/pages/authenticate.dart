import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/sign_in.dart';
import 'package:hidden_gem/services/auth_service.dart';

limport 'package:provider/provider.dart
';

class Authenticate extends StatelessWidget {
  final Widget Function() forward;

  const Authenticate({
    super.key,
    required this.forward
  });

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null && FirebaseAuth.instance.currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user != null) {
      return forward();
    }

    return SignIn();
  }
}