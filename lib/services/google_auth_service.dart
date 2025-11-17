// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class GoogleAuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // 1. FIX: Use the static instance (REQUIRED for v7.2.0)
//   final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
//   // NOTE: Scopes are now usually configured via the native setup (GoogleService-Info.plist / google-services.json)
//   // or a special initialization, but we will rely on the default for simplicity here.

//   Future<User?> signInWithGoogle() async {
//     try {
//       // 2. Use the standard signIn() method for the interactive pop-up
//       // (This is less error-prone than authenticate() for a new login)
//       final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

//       if (googleUser == null) {
//         print("Google sign-in cancelled by user.");
//         return null;
//       }

//       // Step 2: Obtain authentication details
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       // Step 3: Create a credential for Firebase
//       final OAuthCredential credential = GoogleAuthProvider.credential(
//         idToken: googleAuth.idToken,
//         accessToken: null, // Correct
//       );

//       // Step 4: Sign in with Firebase
//       final UserCredential userCredential =
//           await _auth.signInWithCredential(credential);

//       print("✅ Google sign-in successful: ${userCredential.user?.email}");
//       return userCredential.user;
//     } catch (e) {
//       print("❌ Google Sign-In Error: $e");
//       return null;
//     }
//   }

//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//     print("👋 Signed out from Google and Firebase");
//   }
// }

//

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'pin_screen.dart'; // <-- your PinScreen

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   Future<void> signInWithGoogle(BuildContext context) async {
//     try {
//       // Trigger Google Sign-In
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         print("User cancelled sign-in");
//         return; // stop here
//       }

//       // Obtain auth details
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       // Create credential
//       final OAuthCredential credential = GoogleAuthProvider.credential(
//         idToken: googleAuth.idToken,
//         accessToken: googleAuth.accessToken,
//       );

//       // Sign in with Firebase
//       final UserCredential userCredential = await _auth.signInWithCredential(
//         credential,
//       );

//       // ✅ Only navigate if sign-in succeeded
//       if (userCredential.user != null) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const PinScreen()),
//         );
//       } else {
//         print("Sign-in failed, user is null");
//       }
//     } catch (e) {
//       print("Error signing in with Google: $e");
//     }
//   }

//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }

//   User? get currentUser => _auth.currentUser;
//   Stream<User?> get authStateChanges => _auth.authStateChanges();
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  /// Sign out from both Google and Firebase
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
