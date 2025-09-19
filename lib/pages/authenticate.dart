import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hidden_gem/pages/home_page.dart';
import 'package:hidden_gem/pages/sign_in_screen.dart';
import 'package:provider/provider.dart';

class Authenticate extends StatelessWidget {
  const Authenticate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    if (user == null) {
      return SignInScreen();
    } else {
      return HomePage();
    }
  }
}