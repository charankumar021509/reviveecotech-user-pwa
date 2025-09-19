import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class FirebaseServices {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  bool _isGoogleInitialized = false;

  Future<void> _initializeGoogleSignIn() async {
    try {
      await googleSignIn.initialize();
      _isGoogleInitialized = true;
    } catch (e) {
      debugPrint('Google Sign-In initialization failed: $e');
    }
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    if (!_isGoogleInitialized) {
      await _initializeGoogleSignIn();
    }
    try {
      final GoogleSignInAccount? googleUser =
      await googleSignIn.authenticate();

      if (googleUser == null) {
        debugPrint('Sign-in aborted by user');
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint('No ID token retrieved from Google.');
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final userCredential = await auth.signInWithCredential(credential);
      debugPrint('User signed in with Google.');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      return null;
    }
  }

  // Email/Password Signup
  // Future<UserCredential?> signUpWithEmail(String email, String password) async {
  //   try {
  //     final userCredential = await auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     debugPrint('User signed up with email.');
  //     return userCredential;
  //   } on FirebaseAuthException catch (e) {
  //     debugPrint('FirebaseAuthException: ${e.message}');
  //     return null;
  //   } catch (e) {
  //     debugPrint('Error during Email Sign-Up: $e');
  //     return null;
  //   }
  // }
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.sendEmailVerification();

      return null; // no error
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return "This email is already registered.";
        case 'invalid-email':
          return "Invalid email format.";
        case 'weak-password':
          return "Password is too weak.";
        default:
          return "Something went wrong. Please try again.";
      }
    } catch (e) {
      return "Unexpected error. Please try again later.";
    }
  }


  // Email/Password Login
  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('User logged in with email.');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error during Email Login: $e');
      return null;
    }
  }

  // Sign out (Google or Email)
  Future<void> signOut() async {
    try {
      await auth.signOut();
      await googleSignIn.signOut();
      debugPrint('User signed out.');
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
