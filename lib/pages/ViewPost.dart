import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/models/post.dart';
import 'package:hidden_gem/widgets/post_widget.dart';

class ViewPost extends StatelessWidget {
  final User user;
  final Post post;

  const ViewPost({super.key, required this.user, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Post"),
      ),
      body: PostWidget(post: post),
    );
  }
}