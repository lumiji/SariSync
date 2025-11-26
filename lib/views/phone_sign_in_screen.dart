import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sarisync/services/auth_flow_service.dart';
import 'package:sarisync/services/remote_db_service.dart';

class PhoneSignInScreen extends StatefulWidget {
  @override
  _PhoneSignInScreenState createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String verificationId = "";
  bool otpSent = false;

  Future<void> sendOTP() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        //Navigator.pop(context); // Close screen after success
        await RemoteDbService.initializeUserDatabase(uid: userCredential.user!.uid);
        await AuthFlowService.handlePostLogin(context);
      },
      verificationFailed: (error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message.toString())));
      },
      codeSent: (String id, int? token) {
        setState(() {
          verificationId = id;
          otpSent = true;
        });
      },
      codeAutoRetrievalTimeout: (id) {},
    );
  }

  Future<void> verifyOTP() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpController.text.trim(),
    );

    UserCredential userCredential =
      await _auth.signInWithCredential(credential);

  // Create Firestore user + default collections
    await RemoteDbService.initializeUserDatabase(uid: userCredential.user!.uid);

    //Navigator.pop(context); // Close screen after success

    await AuthFlowService.handlePostLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Sign-In")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number (e.g. +639123456789)",
              ),
            ),
            const SizedBox(height: 20),
            if (otpSent)
              TextField(
                controller: otpController,
                decoration: const InputDecoration(labelText: "Enter OTP"),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: otpSent ? verifyOTP : sendOTP,
              child: Text(otpSent ? "Verify OTP" : "Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
