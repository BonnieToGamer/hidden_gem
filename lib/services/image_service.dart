import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:hidden_gem/services/network_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  static final _uuid = Uuid();
  static final Map<String, String> _urlCache = {};

  const ImageService._();

  // Uploads an image to Firebase Storage and returns its UUID.
  // Returns null if the upload fails.
  static Future<String?> uploadImage(File image, String path) async {
    final id = _uuid.v4();

    // Offline
    if (await NetworkService.hasConnection() == false) {
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/$id.img';
      await image.copy(newPath);
      return id;
    }

    final imageRef = FirebaseStorage.instance.ref().child(path).child(id);

    try {
      await imageRef.putFile(image);
      return id;
    } on FirebaseException catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  static Future<File?> getLocalImage(String id) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/$id.img';
    final imageFile = File(imagePath);

    if (await imageFile.exists()) {
      return imageFile;
    } else {
      return null;
    }
  }

  static Future<List<String>> getImageUrls(
    List<String> imageIds,
    String path,
  ) async {
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

  static Future<void> clearOfflineImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      for (final file in files) {
        if (file is File && file.path.endsWith('.img')) {
          await file.delete();
        }
      }
      print("Offline images cleared");
    } catch (e) {
      print("Error clearing offline images: $e");
    }
  }
}
