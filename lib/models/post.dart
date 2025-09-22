import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String authorId;
  final String name;
  final String description;
  final GeoPoint point;
  final Timestamp timestamp;

  Post({
    required this.authorId,
    required this.name,
    required this.description,
    required this.point,
    required this.timestamp,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      authorId: data['authorId'],
      name: data['name'],
      description: data['description'],
      point: data['point'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'name': name,
      'description': description,
      'point': point,
      'timestamp': timestamp,
    };
  }
}