import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/auth/create_user.dart';
import 'package:hidden_gem/pages/auth/sign_in.dart';
import 'package:hidden_gem/pages/auth/verify_email.dart';
import 'package:hidden_gem/services/auth_service.dart';
import 'package:hidden_gem/services/friend_service.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/services/user_service.dart';
import 'package:provider/provider.dart';

class Authenticate extends StatelessWidget {
  final Widget Function() forward;

  const Authenticate({super.key, required this.forward});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AuthState>(context);

    if (state.isLoading) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    final user = state.user;

    if (user == null) {
      return SignIn();
    }

    if (!user.emailVerified) {
      return VerifyEmail(
        onVerified: () async {
          await FirebaseAuth.instance.currentUser?.reload();
          final refreshedUser = FirebaseAuth.instance.currentUser;

          if (refreshedUser != null && refreshedUser.emailVerified) {
            await AuthService.refreshUser();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => CreateUser(
                  name: refreshedUser.displayName ?? "",
                  email: refreshedUser.email!,
                  // Leave blank since we are continuing where we left off
                  password: "",
                  continueBuilding: true,
                ),
              ),
              (_) => false,
            );
          }
        },
      );
    }

    return buildForward(state);
  }

  FutureBuilder<void> buildForward(AuthState state) {
    return FutureBuilder(
      future: loadInitialFriendsData(state.user!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return forward();
      },
    );
  }

  Future<void> loadInitialFriendsData(User user) async {
    await FriendService.acceptSentRequests(user.uid);
    await FriendService.handleDeletedRequests(user.uid);
  }
}
