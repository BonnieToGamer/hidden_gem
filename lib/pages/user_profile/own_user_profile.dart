import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/models/user_info.dart';
import 'package:hidden_gem/pages/user_profile/settings.dart';
import 'package:hidden_gem/services/auth_service.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/widgets/navigation_bar.dart';
import 'package:hidden_gem/widgets/user_profile.dart';
import 'package:provider/provider.dart';

class OwnUserProfile extends StatelessWidget {
  const OwnUserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider
        .of<AuthState>(context, listen: false)
        .user!;

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
      body: UserProfile(user: UserProfileInfo.fromUser(user),
          postStream: PostsService.getOwnPosts(user.uid)),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 2),
    );
  }
}
