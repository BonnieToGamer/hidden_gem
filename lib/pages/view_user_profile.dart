import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/widgets/user_profile.dart';

class ViewUserProfile extends StatelessWidget {
  final User user;

  const ViewUserProfile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${user.displayName}'s profile")),
      body: UserProfile(user: user),
    );
  }
}
