import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  const AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<User?> get userStream => _auth.authStateChanges();
}