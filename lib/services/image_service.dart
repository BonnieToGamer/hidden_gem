import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  static final _uuid = Uuid();
  static final Reference _imagesRef = FirebaseStorage.instance.ref().child(
      "images");
  static final Map<String, String> _urlCache = {};

  const ImageService._();

  // Uploads an image to Firebase Storage and returns its UUID.
  // Returns null if the upload fails.
  static Future<String?> uploadImage(File image) async {
    final id = _uuid.v4();
    final imageRef = _imagesRef.child(id);

    try {
      await imageRef.putFile(image);
      return id;
    } on FirebaseException catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  static Future<List<String>> getImageUrls(List<String> imageIds) async {
    return Future.wait(imageIds.map((id) => getImageUrl(id)));
  }

  static Future<String> getImageUrl(String imageId) async {
    if (_urlCache.containsKey(imageId)) {
      return _urlCache[imageId]!;
    }

    final ref = _imagesRef.child(imageId);
    final url = await ref.getDownloadURL();

    _urlCache[imageId] = url;
    return url;
  }

  static Future<void> deleteImage(String id) async {
    try {
      await _imagesRef.child(id).delete();
    } catch (e) {
      print("Error deleting image: $e");
    }
  }
}
