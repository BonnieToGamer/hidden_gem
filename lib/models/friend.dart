import 'package:cloud_firestore/cloud_firestore.dart';

class FriendData {
  String id;
  String friendId;
  Timestamp timestamp;

  FriendData({
    required this.id,
    required this.friendId,
    required this.timestamp,
  });

  factory FriendData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendData(
      id: doc.id,
      friendId: data['friendId'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'friendId': friendId, 'timestamp': timestamp};
  }
}
