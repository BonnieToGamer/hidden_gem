import 'package:flutter/material.dart';
import 'package:hidden_gem/models/user_info.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/widgets/user_profile.dart';

class ViewUserProfile extends StatelessWidget {
  final UserProfileInfo user;

  const ViewUserProfile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${user.name}'s profile")),
      body: UserProfile(
          user: user, postStream: PostsService.getUsersPosts(user.uid)),
    );
  }
}
