import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  final storage = FirebaseStorage.instance;
  final uuid = Uuid();
  final Reference imagesRef;

  ImageService() : imagesRef = FirebaseStorage.instance.ref().child("images");

  // Uploads an image to Firebase Storage and returns its UUID.
  // Returns null if the upload fails.
  Future<String?> uploadImage(File image) async {
    final id = uuid.v4();
    final imageRef = imagesRef.child("$id.png");

    try {
      await imageRef.putFile(image);
      return id;
    } on FirebaseException catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}