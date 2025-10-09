import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest {
  final String id;
  final String fromId;
  final String toId;
  final String status;
  final Timestamp timestamp;

  FriendRequest({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.status,
    required this.timestamp,
  });

  factory FriendRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendRequest(
      id: doc.id,
      fromId: data['fromId'],
      toId: data['toId'],
      status: data['status'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromId': fromId,
      'toId': toId,
      'status': status,
      'timestamp': timestamp
    };
  }
}
