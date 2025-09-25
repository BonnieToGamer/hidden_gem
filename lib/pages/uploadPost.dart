import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:hidden_gem/pages/home_page.dart';
import 'package:hidden_gem/services/image_service.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:oktoast/oktoast.dart';

class UploadPost extends StatefulWidget {
  final User user;
  final String name;
  final String description;
  final GeoPoint point;
  final List<File> images;
  final imageService = ImageService();
  final postService = PostsService();

  UploadPost({super.key, required this.user, required this.name, required this.description, required this.point, required this.images});

  @override
  State<StatefulWidget> createState() => _UploadPostState();

}

class _UploadPostState extends State<UploadPost> {
  bool _isLoading = false;
  bool _confettiLaunched = false;

  @override
  void initState() {
    super.initState();

    post();
  }

  Future<void> post() async {
    setState(() {
      _isLoading = true;
    });

    List<String> imageIds = [];

    for (File image in widget.images) {
      String? result = await widget.imageService.uploadImage(image);
      if (result == null) {
        showToast("Failed to upload one of the images");
        return;
      }
      imageIds.add(result);
    }

    await widget.postService.createPost(
      widget.user,
      widget.name,
      widget.description,
      widget.point,
      Timestamp.now(),
      imageIds
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page(context),
    );
  }

  Widget _page(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      if (!_confettiLaunched) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Confetti.launch(
            context,
            options: ConfettiOptions(
              particleCount: 200,
              spread: 45,
              startVelocity: 80,
              decay: 0.9,
              y: 1.25,
            ),
          );
        });

        _confettiLaunched = true;
      }

      return Center(
        child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                "Upload Successful!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage(user: widget.user)), (route) => false);
                },
                child: const Text("Back"),
              ),
            ],
          )
      );
    }
  }
}