import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


Future<void> signOutUser() async {
  try {
    // Firebase Sign Out
    await FirebaseAuth.instance.signOut();

    // Google Sign Out
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (e) {
      // ignore google signout errors
    }

    // Facebook Sign Out
    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      // ignore facebook signout errors
    }

    print("Signed out successfully");
  } catch (e) {
    print("Error signing out: $e");
  }
}
