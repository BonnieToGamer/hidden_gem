import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:hidden_gem/models/post.dart';
import 'package:latlong2/latlong.dart';

class PostsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = "posts";

  Future<void> addPost(Post post) async {
    await _db.collection(_collectionPath).add(post.toMap());
  }

  Future<void> createPost(User author, String name, String description, GeoFirePoint point, Timestamp timestamp, List<String> imageIds) async {
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

  // make this actually work :(
  // Stream<List<Post>> getPosts(LatLng center, double radiusInKm) {
  //   final collectionReference = _db.collection("posts").withConverter<Post>(
  //       fromFirestore: (ds, _) => Post.fromFirestore(ds),
  //       toFirestore: (obj, _) => obj.toMap()
  //   );
  //
  //   // final stream = GeoCollectionReference(collectionReference)
  //   //   .subscribeWithin(
  //   //     center: GeoFirePoint(GeoPoint(center.latitude, center.longitude)),
  //   //     radiusInKm: radiusInKm,
  //   //     field: 'point',
  //   //     geopointFrom: (Post data) => data.point.geopoint
  //   // );
  //   //
  //   // return stream.map((snapshots) =>
  //   //   snapshots.map(
  //   //           (docSnap) => docSnap.data()!
  //   //   ).toList()
  //   // );
  // }
}