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

// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class FacebookAuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   /// Sign in with Facebook
//   /// [forceLogin]:
//   /// - true → always show Facebook login dialog (for testing new user)
//   /// - false → normal auto-login if token exists (production)
//   Future<User?> signInWithFacebook({bool forceLogin = false}) async {
//     try {
//       // If testing, force logout to show login dialog
//       if (forceLogin) {
//         await FacebookAuth.instance.logOut();
//       }

//       // Trigger Facebook login
//       final LoginResult user = await FacebookAuth.instance.login(
//         permissions: ['public_profile', 'email'],
//         loginBehavior: forceLogin
//             ? LoginBehavior.dialogOnly // force dialog during testing
//             : LoginBehavior.nativeWithFallback, // normal behavior
//       );

//       // final user = await FacebookAuth.instance.login(
//       //   permissions: ['public_profile', 'email'],
//       //   loginBehavior: LoginBehavior.webOnly, // forces consistent login dialog
//       // );

//       if (user.status == LoginStatus.success) {
//         final AccessToken? accessToken = user.accessToken;
//         if (accessToken == null) {
//           print('Error: AccessToken is null');
//           return null;
//         }

//         // Firebase credential
//         final OAuthCredential facebookCredential =
//             FacebookAuthProvider.credential(accessToken.token);

//         // Sign in with Firebase
//         UserCredential userCredential = await _auth.signInWithCredential(
//           facebookCredential,
//         );

//         return userCredential.user;
//       } else if (user.status == LoginStatus.cancelled) {
//         print('Facebook login cancelled by user.');
//         return null;
//       } else {
//         print('Facebook login failed: ${user.message}');
//         return null;
//       }
//     } catch (e) {
//       print('Error during Facebook login: $e');
//       return null;
//     }
//   }

//   /// Sign out
//   Future<void> signOut() async {
//     await FacebookAuth.instance.logOut();
//     await _auth.signOut();
//   }
// }
