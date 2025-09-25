import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class Post {
  final String authorId;
  final String name;
  final String description;
  final GeoFirePoint point;
  final Timestamp timestamp;
  final List<String> imageIds;

  Post({
    required this.authorId,
    required this.name,
    required this.description,
    required this.point,
    required this.timestamp,
    required this.imageIds,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final pointData = data['point'] as Map<String, dynamic>;
    final geoPoint = pointData['geopoint'] as GeoPoint;

    return Post(
      authorId: data['authorId'],
      name: data['name'],
      description: data['description'],
      point: GeoFirePoint(geoPoint),
      timestamp: data['timestamp'],
      imageIds: List<String>.from(data['imageIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'name': name,
      'description': description,
      'point': point.data,
      'timestamp': timestamp,
      'imageIds': imageIds,
    };
  }
}