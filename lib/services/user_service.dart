import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hidden_gem/models/user_info.dart';

class UserService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final String _collectionPath = "users";

  const UserService._();

  static Future<void> createUser(User user) async {
    final usersRef = _db.collection(_collectionPath);

    await usersRef.doc(user.uid).set({
      'name': user.displayName,
      'avatar': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> createUserManual(
    String uid,
    String name,
    String photoUrl,
  ) async {
    final usersRef = _db.collection(_collectionPath);

    await usersRef.doc(uid).set({
      'name': name,
      'avatar': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<UserProfileInfo> getUser(String uid) async {
    final usersRef = _db.collection(_collectionPath);
    final doc = await usersRef.doc(uid).get();
    return UserProfileInfo.fromFirestore(doc);
  }
}
