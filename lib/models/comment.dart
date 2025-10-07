import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String? id;
  final String userId;
  final String postId;
  final String content;
  final Timestamp timestamp;

  Comment({
    required this.userId,
    required this.postId,
    required this.timestamp,
    required this.content,
    this.id,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userId: data['userId'],
      postId: data['postId'],
      content: data['content'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'postId': postId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
