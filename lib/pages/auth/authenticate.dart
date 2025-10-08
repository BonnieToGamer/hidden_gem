import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/auth/sign_in.dart';
import 'package:hidden_gem/services/auth_service.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:provider/provider.dart';

class Authenticate extends StatelessWidget {
  final Widget Function() forward;

  const Authenticate({super.key, required this.forward});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AuthState>(context);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.user != null) {
      return FutureBuilder(future: PostsService.getFriendIds(state.user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return forward();
          });
    }

    return SignIn();
  }
}
