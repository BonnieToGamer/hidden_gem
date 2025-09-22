import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// https://pub.dev/packages/photo_manager#android-config-preparation

class CreatePost extends StatefulWidget {
  final User user;

  CreatePost({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    initAsync();
  }

  Future<void> initAsync() async {
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}