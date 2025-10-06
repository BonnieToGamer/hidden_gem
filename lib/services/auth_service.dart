import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AuthState {
  final bool isLoading;
  final User? user;

  AuthState._({required this.isLoading, this.user});

  factory AuthState.loading() => AuthState._(isLoading: true);

  factory AuthState.authenticated(User user) =>
      AuthState._(isLoading: false, user: user);

  factory AuthState.unauthenticated() => AuthState._(isLoading: false);
}

class AuthService {
  const AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<AuthState> get authStateChanges {
    return _auth.authStateChanges().map<AuthState>((user) {
      if (user != null) {
        return AuthState.authenticated(user);
      } else {
        return AuthState.unauthenticated();
      }
    }).startWith(AuthState.loading());
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<User?> signUpUser(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print("The password provided was too weak.");
      } else if (e.code == 'email-already-in-use') {
        print("The account already exists for that email.");
      }
    } catch (e) {
      print(e);
    }

    return null;
  }

  static Future<User?> signInUser(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        print("Wrong password provided for that user.");
      }
    } catch (e) {
      print(e);
    }

    return null;
  }

  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();
      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      return userCredential.user;
    } catch (e) {
      print("Sign-in error: $e");
      return null;
    }
  }

  static Future<void> forgotPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (err) {
      print("Error sending password reset (auth exception): ${err.message
          .toString()}");
      throw Exception(err.message.toString());
    } catch (err) {
      print("Error sending password reset (*): ${err.toString()}");
      throw Exception(err.toString());
    }
  }
}
