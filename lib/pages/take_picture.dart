import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/constants.dart';
import 'package:hidden_gem/pages/new_post.dart';

// https://docs.flutter.dev/cookbook/plugins/picture-using-camera

class TakePicture extends StatefulWidget {
  const TakePicture({super.key});

  @override
  State<StatefulWidget> createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final List<XFile> _images = [];
  bool takingPicture = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    if (!mounted) return;

    setState(() {
      _controller = CameraController(camera, ResolutionPreset.high);
      _initializeControllerFuture = _controller!.initialize();
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Take up to $maxImagesPerPost pictures")),
      body: Column(
        verticalDirection: VerticalDirection.down,
        children: [
          _controller != null
              ? Expanded(child: _cameraSLot())
              : const Center(child: CircularProgressIndicator()),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _images.removeAt(index);
                      });
                    },
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.file(
                              File(_images[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 2.0,
                            left: 2.0,
                            child: Icon(
                              Icons.cancel,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _images.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                List<File> images = _images
                    .map((img) => File(img.path))
                    .toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewPost(images: images),
                  ),
                );
              },
              child: Icon(Icons.send),
            )
          : null,
    );
  }

  void _takePicture() async {
    if (takingPicture ||
        _controller == null ||
        !_controller!.value.isInitialized)
      return;

    setState(() {
      takingPicture = true;
    });

    try {
      if (_images.length >= maxImagesPerPost) return;

      await _initializeControllerFuture;

      final image = await _controller!.takePicture();

      if (!mounted) return;

      setState(() {
        _images.add(image);
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        takingPicture = false;
      });
    }
  }

  FutureBuilder<void> _cameraSLot() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _cameraPreview(context);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _cameraPreview(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(_controller!)),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
              onPressed: _takePicture,
              child: Icon(Icons.circle_outlined, color: Colors.white, size: 50),
            ),
          ),
        ),
      ],
    );
  }
}
