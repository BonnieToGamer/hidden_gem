import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileInfo {
  final String uid;
  final String name;
  final String avatar;

  UserProfileInfo({
    required this.uid,
    required this.name,
    required this.avatar,
  });

  factory UserProfileInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileInfo(
      uid: data['uid'],
      name: data['name'],
      avatar: data['avatar'],
    );
  }

  factory UserProfileInfo.fromUser(User user) {
    return UserProfileInfo(
      uid: user.uid,
      name: user.displayName ?? '',
      avatar: user.photoURL ?? '',
    );
  }
}
