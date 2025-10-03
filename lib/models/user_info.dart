import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileInfo {
  final String name;
  final String avatar;

  UserProfileInfo({required this.name, required this.avatar});

  factory UserProfileInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileInfo(name: data['name'], avatar: data['avatar']);
  }
}
