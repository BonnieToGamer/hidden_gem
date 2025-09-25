import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hidden_gem/constants.dart';
import 'package:hidden_gem/pages/pick_on_map.dart';
import 'package:hidden_gem/pages/uploadPost.dart';
import 'package:hidden_gem/services/geo_locator_service.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/widgets/navigation_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:oktoast/oktoast.dart';
import 'package:carousel_slider/carousel_slider.dart';

class NewPost extends StatefulWidget {
  final User user;
  final List<File> images;

  const NewPost({super.key, required this.user, required this.images});

  @override
  State<StatefulWidget> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final double _formPaddingHorizontal = 16.0;
  LatLng? _selectedPosition;
  bool _loadingCurrentLocation = false;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _geoController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _geoController = TextEditingController();
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
      appBar: AppBar(
        title: Text("New post"),
      ),
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
                      padding: EdgeInsets.symmetric(horizontal: _formPaddingHorizontal),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FilledButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => PickOnMap(callback: (location) {
                                    _setLocation(location);
                                  })));
                                },
                                child: const Text("Pick on map")
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
                                    final highAccuracyPosition = await GeolocatorService.getCurrentLocation(accuracy: LocationAccuracy.high);
                                    LatLng location = LatLng(highAccuracyPosition.latitude, highAccuracyPosition.longitude);
                                    _setLocation(location);
                                    setState(() {
                                      _loadingCurrentLocation = false;
                                    });
                                  },
                                  child: const Text("Pick current location")
                              ),
                            ],
                          ),
                          _loadingCurrentLocation ? const CircularProgressIndicator() : TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: _formDecoration("No location selected"),
                            style: _formStyle(),
                            validator: (String? text) {
                              if (text == null || text.isEmpty) {
                                return "Please select a location";
                              }

                              return null;
                            },
                            enabled: false,
                            controller: _geoController,
                          )
                        ],
                      ),
                    )
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
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(),
                ),
                onPressed: _createPost,
                child: const Text("Submit")
              )
            ),
          )
        ]
      ),
    );
  }

  void _createPost() {
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
            images: widget.images,
          )
      ));
    }
  }

  void _setLocation(LatLng location) {
    setState(() {
      _selectedPosition = location;
      _geoController.text = "Location: ${_selectedPosition!.latitude.toStringAsFixed(6)}, ${_selectedPosition!.longitude.toStringAsFixed(6)}";
    });
  }

  Divider _buildDivider(BuildContext context) => Divider(height: 1.0, thickness: 0.1, color: Theme.of(context).colorScheme.primary,);

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
    return TextStyle(
          fontSize: 14
      );
  }

  InputDecoration _formDecoration(String hintText) {
    return InputDecoration(
        border: InputBorder.none,
        hintText: hintText,
      );
  }

  CarouselSlider _buildCarouselSlider(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        enableInfiniteScroll: false,
        autoPlay: false,
        initialPage: 0,
        height: 300,
        disableCenter: true,
        enlargeCenterPage: false,

      ),
      items: widget.images.map((img) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Image.file(
              File(img.path),
              fit: BoxFit.scaleDown
          )
        );
      }).toList(),
    );
  }
}