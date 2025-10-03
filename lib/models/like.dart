import 'package:cloud_firestore/cloud_firestore.dart';

class Like {
  final String userId;
  final String postId;
  final Timestamp timestamp;

  Like({required this.userId, required this.postId, required this.timestamp});

  factory Like.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Like(
      userId: data['userId'],
      postId: data['postId'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'postId': postId, 'timestamp': timestamp};
  }
}
