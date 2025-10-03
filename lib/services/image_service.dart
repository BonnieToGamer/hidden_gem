import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  static final _uuid = Uuid();
  static final Map<String, String> _urlCache = {};

  const ImageService._();

  // Uploads an image to Firebase Storage and returns its UUID.
  // Returns null if the upload fails.
  static Future<String?> uploadImage(File image, String path) async {
    final id = _uuid.v4();
    final imageRef = FirebaseStorage.instance.ref().child(path).child(id);

    try {
      await imageRef.putFile(image);
      return id;
    } on FirebaseException catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  static Future<List<String>> getImageUrls(List<String> imageIds,
      String path) async {
    return Future.wait(imageIds.map((id) => getImageUrl(id, path)));
  }

  static Future<String> getImageUrl(String imageId, String path) async {
    if (_urlCache.containsKey(imageId)) {
      return _urlCache[imageId]!;
    }

    final ref = FirebaseStorage.instance.ref().child(path).child(imageId);
    final url = await ref.getDownloadURL();

    _urlCache[imageId] = url;
    return url;
  }

  static Future<void> deleteImage(String id, String path) async {
    try {
      await FirebaseStorage.instance.ref().child(path).child(id).delete();
    } catch (e) {
      print("Error deleting image: $e");
    }
  }
}
