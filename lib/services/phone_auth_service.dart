import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  // Step 1: Send OTP
  Future<void> sendOTP({
    required String phoneNumber,
    required VoidCallback onCodeSent,
    required VoidCallback onAutoVerified,
    required Function(String error) onFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber.trim(),

      // 🔥 Auto verification if Google confirms silently
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        onAutoVerified(); // go to set pin immediately
      },

      // ❌ Failed verification
      verificationFailed: (FirebaseAuthException e) {
        onFailed(e.message ?? "Phone verification failed");
      },

      // 📩 OTP sent to SMS
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent();
      },

      // ⏳ Timeout - allow input manually
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // Step 2: Verify OTP
  Future<User?> verifyOTP({
    required String smsCode,
    required Function(String error) onFailed,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode.trim(),
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      onFailed("Invalid or expired OTP");
      return null;
    }
  }
}
