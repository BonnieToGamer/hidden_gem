import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:hidden_gem/models/user_info.dart';
import 'package:hidden_gem/pages/authenticate.dart';
import 'package:hidden_gem/pages/home_page.dart';
import 'package:hidden_gem/services/image_service.dart';
import 'package:latlong2/latlong.dart';

class UploadPost extends StatefulWidget {
  final UserProfileInfo user;
  final String name;
  final String description;
  final LatLng point;
  final List<File> images;
  final bool isPublic;
  final bool uploadImages;
  final Function(
    UserProfileInfo author,
    String name,
    String description,
    GeoFirePoint point,
    Timestamp timestamp,
    List<String> imageIds,
    bool isPublic,
  )
  uploadFunction;

  UploadPost({
    super.key,
    required this.user,
    required this.name,
    required this.description,
    required this.point,
    required this.images,
    required this.isPublic,
    required this.uploadImages,
    required this.uploadFunction,
  });

  @override
  State<StatefulWidget> createState() => _UploadPostState();
}

class _UploadPostState extends State<UploadPost> {
  bool _isLoading = false;
  bool _confettiLaunched = false;
  String _statusText = "";

  @override
  void initState() {
    super.initState();

    post();
  }

  Future<void> post() async {
    setState(() {
      _isLoading = true;
      _statusText = "Uploading images";
    });

    List<String> imageIds = [];
    int index = 0;
    int maxIndex = widget.images.length;

    if (widget.uploadImages) {
      for (File image in widget.images) {
        setState(() {
          _isLoading = true;
          _statusText = "Uploading image ${index + 1} of $maxIndex";
        });

        String? result = await ImageService.uploadImage(image, "images");
        if (result == null) {
          final snackBar = SnackBar(
              content: const Text("Failed to upload one of the images")
          );

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return;
        }
        imageIds.add(result);
      }
    }

    if (!mounted) return;

    setState(() {
      _statusText = "Uploading post";
    });

    final geoPoint = GeoFirePoint(
      GeoPoint(widget.point.latitude, widget.point.longitude),
    );

    await widget.uploadFunction(
      widget.user,
      widget.name,
      widget.description,
      geoPoint,
      Timestamp.now(),
      imageIds,
      widget.isPublic,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _statusText = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _page(context));
  }

  Widget _page(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _statusText,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      );
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
        child: Column(
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Authenticate(forward: () => HomePage()),
                  ),
                  (route) => false,
                );
              },
              child: const Text("Back"),
            ),
          ],
        ),
      );
    }
  }
}
