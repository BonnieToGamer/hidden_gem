import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hidden_gem/constants.dart';
import 'package:hidden_gem/models/post.dart';
import 'package:hidden_gem/pages/pick_on_map.dart';
import 'package:hidden_gem/pages/upload_post.dart';
import 'package:hidden_gem/services/geo_locator_service.dart';
import 'package:hidden_gem/services/image_service.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/widgets/navigation_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:oktoast/oktoast.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EditPost extends StatefulWidget {
  final User user;
  Post post;

  EditPost({super.key, required this.user, required this.post});

  @override
  State<StatefulWidget> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final double _formPaddingHorizontal = 16.0;
  LatLng? _selectedPosition;
  bool _loadingCurrentLocation = false;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _geoController;
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _geoController = TextEditingController();

    _nameController.text = widget.post.name;
    _descriptionController.text = widget.post.description;
    _selectedPosition = LatLng(
      widget.post.point.geopoint.latitude,
      widget.post.point.geopoint.longitude,
    );
    _geoController.text = _posToString();
    _isPublic = widget.post.isPublic;
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _geoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("Edit post")),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildCarouselSlider(context),
                    _buildGemName(),
                    _buildDivider(context),
                    _buildGemDescription(),
                    _buildDivider(context),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: _formPaddingHorizontal,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FilledButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PickOnMap(
                                        callback: (location) {
                                          _setLocation(location);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("Pick on map"),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("-or-"),
                              ),
                              FilledButton(
                                onPressed: () async {
                                  setState(() {
                                    _loadingCurrentLocation = true;
                                  });
                                  final highAccuracyPosition =
                                      await GeolocatorService.getCurrentLocation(
                                        accuracy: LocationAccuracy.high,
                                      );
                                  LatLng location = LatLng(
                                    highAccuracyPosition.latitude,
                                    highAccuracyPosition.longitude,
                                  );
                                  _setLocation(location);
                                  setState(() {
                                    _loadingCurrentLocation = false;
                                  });
                                },
                                child: const Text("Pick current location"),
                              ),
                            ],
                          ),
                          _loadingCurrentLocation
                              ? Padding(
                                  padding: EdgeInsets.all(
                                    _formPaddingHorizontal,
                                  ),
                                  child: const CircularProgressIndicator(),
                                )
                              : TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: _formDecoration(
                                    "No location selected",
                                  ),
                                  style: _formStyle(),
                                  validator: (String? text) {
                                    if (text == null || text.isEmpty) {
                                      return "Please select a location";
                                    }

                                    return null;
                                  },
                                  enabled: false,
                                  controller: _geoController,
                                ),
                        ],
                      ),
                    ),
                    _buildDivider(context),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: _formPaddingHorizontal,
                      ),
                      child: Row(
                        children: [
                          Text("Is post public?"),
                          Checkbox(
                            value: _isPublic,
                            onChanged: (bool? value) {
                              setState(() {
                                _isPublic = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(shape: RoundedRectangleBorder()),
                onPressed: _editPost,
                child: const Text("Edit"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editPost() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPosition == null) {
        showToast("Selected position was null");
        return;
      }

      Navigator.push(context, MaterialPageRoute(
        builder: (context) =>
          UploadPost(
            user: widget.user,
            name: _nameController.text,
            description: _descriptionController.text,
            point: _selectedPosition!,
            images: [], // TODO: maybe in the future
            isPublic: _isPublic,
            uploadImages: false,
            uploadFunction: (User author, String name, String description, GeoFirePoint point, Timestamp timestamp, List<String> imageIds, bool isPublic) {
              Post newPost = Post(authorId: author.uid, name: name, description: description, point: point, timestamp: timestamp, imageIds: widget.post.imageIds, isPublic: isPublic, postId: widget.post.postId);
              PostsService.updatePost(newPost);
            },
          )
      ));
    }
  }

  void _setLocation(LatLng location) {
    setState(() {
      _selectedPosition = location;
      _geoController.text = _posToString();
    });
  }

  String _posToString() =>
      "Location: ${_selectedPosition!.latitude.toStringAsFixed(6)}, ${_selectedPosition!.longitude.toStringAsFixed(6)}";

  Divider _buildDivider(BuildContext context) => Divider(
    height: 1.0,
    thickness: 0.1,
    color: Theme.of(context).primaryColor,
  );

  Widget _buildGemName() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _formPaddingHorizontal),
      child: TextFormField(
        decoration: _formDecoration("Add a name"),
        style: _formStyle(),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return "Please enter a name";
          }

          if (value.length >= maxNameLength) {
            return "Gem names can only be $maxNameLength characters long";
          }

          return null;
        },
        controller: _nameController,
      ),
    );
  }

  Widget _buildGemDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _formPaddingHorizontal),
      child: TextFormField(
        decoration: _formDecoration("Add a description"),
        style: _formStyle(),
        keyboardType: TextInputType.multiline,
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return "Please enter a description";
          }

          if (value.length >= maxDescriptionLength) {
            return "Gem descriptions can only be $maxDescriptionLength characters long";
          }

          return null;
        },
        controller: _descriptionController,
      ),
    );
  }

  TextStyle _formStyle() {
    return TextStyle(fontSize: 14);
  }

  InputDecoration _formDecoration(String hintText) {
    return InputDecoration(border: InputBorder.none, hintText: hintText);
  }

  Widget _buildCarouselSlider(BuildContext context) {
    return FutureBuilder(
      future: ImageService.getImageUrls(widget.post.imageIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text("Error loading images");
        }

        final urls = snapshot.data ?? [];
        return CarouselSlider(
          options: CarouselOptions(
            enableInfiniteScroll: false,
            autoPlay: false,
            initialPage: 0,
            height: 300,
            disableCenter: true,
            enlargeCenterPage: false,
          ),
          items: urls.map((url) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              child: Image.network(
                url,
                fit: BoxFit.scaleDown,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return SizedBox(
                    width: double.infinity,
                    height: 150,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
