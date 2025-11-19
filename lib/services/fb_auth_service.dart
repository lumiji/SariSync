import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacebookAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with Facebook
  Future<User?> signInWithFacebook() async {
    try {
      // Trigger Facebook login
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (result.status == LoginStatus.success) {
        // Get the Facebook Access Token safely
        final AccessToken? accessToken = result.accessToken;

        if (accessToken == null) {
          print('Error: AccessToken is null');
          return null;
        }

        // Create a credential for Firebase
        final OAuthCredential facebookCredential =
            FacebookAuthProvider.credential(accessToken.token);

        // Sign in with Firebase
        UserCredential userCredential =
            await _auth.signInWithCredential(facebookCredential);

        return userCredential.user;
      } else if (result.status == LoginStatus.cancelled) {
        print('Facebook login cancelled by user.');
        return null;
      } else {
        print('Facebook login failed: ${result.message}');
        return null;
      }
    } catch (e) {
      print('Error during Facebook login: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }
}
