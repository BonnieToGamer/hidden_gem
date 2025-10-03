import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/settings.dart';
import 'package:hidden_gem/widgets/navigation_bar.dart';
import 'package:hidden_gem/widgets/user_profile.dart';

class OwnUserProfile extends StatelessWidget {
  final User user;

  const OwnUserProfile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${user.displayName}'s profile"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
            },
            icon: Icon(Icons.settings, color: Theme.of(context).primaryColor),
          ),
        ],
      ),
      body: UserProfile(user: user),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 2, user: user),
    );
  }
}
