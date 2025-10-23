import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String? id;
  final String userId;
  final String postId;
  final Timestamp timestamp;

  Report({
    required this.userId,
    required this.postId,
    required this.timestamp,
    this.id,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      userId: data['userId'],
      postId: data['postId'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'postId': postId, 'timestamp': timestamp};
  }
}
