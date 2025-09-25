import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hidden_gem/models/post.dart';

class PostsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = "posts";

  Future<void> addPost(Post post) async {
    await _db.collection(_collectionPath).add(post.toMap());
  }

  Future<void> createPost(User author, String name, String description, GeoPoint point, Timestamp timestamp, List<String> imageIds) async {
    try {
      final post = Post(authorId: author.uid, name: name, description: description, point: point, timestamp: timestamp, imageIds: imageIds);
      await _db.collection(_collectionPath).add(post.toMap());
    } catch (e) {
      print("Error");
    }
  }

  Stream<List<Post>> getPosts() {
    return _db
      .collection(_collectionPath)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) =>
        snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }
}