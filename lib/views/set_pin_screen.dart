import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sarisync/services/local_storage_service.dart';
import 'sign-in_options.dart';
import 'pin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sarisync/models/pending_registration.dart';
import 'package:sarisync/services/remote_db_service.dart';


class SetPinScreen extends StatefulWidget {
  final String? accountIdentifier; // Can be phone, email, or any account identifier
  final String? accountType; // 'phone', 'google', 'facebook', etc.
  final PendingRegistration? pendingRegistration;
  
  const SetPinScreen({
    super.key,
      this.accountIdentifier,
      this.accountType,
      this.pendingRegistration
    });

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String? _existingPin;
  String _enteredPin = '';
  String _errorMessage = '';
  String? _pressedKey;
  String? _displayAccount;
  String? _accountType;

  @override
  void initState() {
    super.initState();
    _loadAccountInfo();
  }

  Future<void> _loadAccountInfo() async {
    
    String? account = widget.accountIdentifier ?? await LocalStorageService.getAccountIdentifier();
    String? type = widget.accountType ?? await LocalStorageService.getAccountType();
    String? existingPin;

     if (account != null) {
      // Query Firestore for a user document where username/email/phone == account
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: account) // or 'email' / 'phone'
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        existingPin = query.docs.first.data()['pinHash'];
      }
    }


    setState(() {
      _displayAccount = account;
      _accountType = type;
      _existingPin = existingPin;
    });
  }


  IconData _getAccountIcon() {
    switch (_accountType?.toLowerCase()) {
      case 'google':
        return Icons.email_outlined;
      case 'facebook':
        return Icons.facebook;
      case 'phone':
      default:
        return Icons.phone_outlined;
    }
  }

  void _onNumberTap(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;

        // Clear error if user types again
        if (_errorMessage.isNotEmpty) _errorMessage = '';
      });
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);

        // Clear error when PIN becomes empty
        if (_enteredPin.isEmpty && _errorMessage.isNotEmpty) {
          _errorMessage = '';
        }
      });
    }
  }

  void _onSubmit() async {
      if (_enteredPin.length != 4) {
        setState(() => _errorMessage = 'Enter 4 digits');
        return;
      }
      setState(() => _errorMessage = '');

      // Check for existing PIN first
      if (_existingPin != null) {
        _showExistingPinDialog();
      } else {
        await _saveNewPinFlow();
      }
    }

  void _showExistingPinDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Existing Account"),
        content: const Text(
            "An account with this identifier already has a PIN. What would you like to do?"),
        actions: [
          TextButton(
            child: const Text("Enter existing PIN"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PinScreen(
                  accountIdentifier: _displayAccount,
                  accountType: _accountType,
                )),
              );
            },
          ),
          TextButton(
            child: const Text("Set a new PIN"),
            onPressed: () {
              Navigator.pop(context);
              _saveNewPinFlow();
            },
          ),
        ],
      ),
    );
  }


 // In SetPinScreen, when PIN is confirmed:
Future<void> _saveNewPinFlow() async {
  final pending = widget.pendingRegistration;

  if (pending == null) {
    // Existing user flow
    final account = await LocalStorageService.getAccountIdentifier();
    if (account == null) {
      setState(() => _errorMessage = 'Account not found');
      return;
    }
    
    await LocalStorageService.savePin(account, _enteredPin);
    await LocalStorageService.saveLoggedIn();
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final pinHash = sha256.convert(utf8.encode(_enteredPin)).toString();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'pinHash': pinHash});
    }
    
    if (context.mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => PinScreen()));
    }
    return;
  }

  // New user registration flow
  try {
    UserCredential? userCredential;

    // Creating Firebase account based on type
    switch (pending.accountType) {
      case 'password':
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: pending.email!,
          password: pending.password!,
        );
        break;

      case 'google':
        final credential = GoogleAuthProvider.credential(
          idToken: pending.googleIdToken,
          accessToken: pending.googleAccessToken,
        );
        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        break;

      case 'facebook':
        final credential = FacebookAuthProvider.credential(pending.facebookAccessToken!);
        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        break;

      case 'phone':
        final credential = PhoneAuthProvider.credential(
          verificationId: pending.phoneVerificationId!,
          smsCode: pending.phoneCode!,
        );
        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        break;
    }

    if (userCredential != null) {
      final uid = userCredential.user!.uid;

      // Initialize Firestore
      await RemoteDbService.initializeUserDatabase(uid: uid);

      // Save account info FIRST
      await LocalStorageService.saveAccountInfo(
        pending.displayIdentifier, 
        pending.accountType
      );
      
      // NOW save PIN with the correct identifier
      await LocalStorageService.savePin(pending.displayIdentifier, _enteredPin);

      // Save hashed PIN to Firebase
      final pinHash = sha256.convert(utf8.encode(_enteredPin)).toString();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'username': pending.displayIdentifier,
            'email': pending.email ?? userCredential.user!.email,
            'phone': pending.accountType == 'phone' ? userCredential.user!.phoneNumber : null,
            'accountType': pending.accountType,
            'pinHash': pinHash,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // Mark as logged in
      await LocalStorageService.saveLoggedIn();

      // Navigate to PIN screen
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PinScreen()),
        );
      }
    }
  } on FirebaseAuthException catch (e) {
    String _errorMessage;

    switch (e.code) {
      case 'email-already-in-use': 
        _errorMessage = 'This email is already registered. Please log in instead.';
        break;
      case 'invalid-email':
      _errorMessage = 'Invalid email address.';
      break;
      case 'weak-password':
        _errorMessage = 'Password is too weak. Please use at least 6 characters.';
        break;
      case 'operation-not-allowed':
        _errorMessage = 'Email/password accounts are not enabled.';
        break;
      case 'account-exists-with-different-credential':
        _errorMessage = 'An account already exists with this email using a different sign-in method.';
        break;
      default:
        _errorMessage = 'Error: ${e.message}';
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage),
          backgroundColor: Color(0xFFE53935),
          duration: Duration(seconds: 4),)
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error creating account: $e")),
        );
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with blur effect
          Image.asset('assets/images/background.png', fit: BoxFit.fill),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),

          // Content layout
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // Logo and text
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "SariSync",
                        style: TextStyle( fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tagline
              Text(
                "Smooth sales, smooth days.",
                style: TextStyle( fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 30),

              // Account display (phone, email, or social media account)
              if (_displayAccount != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getAccountIcon(),
                        color: const Color(0xFF1E88E5),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _displayAccount!,
                          style: TextStyle( fontFamily: 'Inter',
                            fontSize: 16,
                            color: const Color(0xFF1E88E5),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed:  () => _handleSwitchAccount(context),
                          icon: const Icon(
                            Icons.swap_horiz,
                            color: Color(0xFF1E88E5),
                            size: 24,
                          ),
                        ),

                    ],
                  ),
                ),

              const SizedBox(height: 40),

              // Set PIN text
              Text(
                "Set PIN",
                style: TextStyle( fontFamily: 'Inter',
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              // PIN circles
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  bool filled = index < _enteredPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: filled ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  );
                }),
              ),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle( fontFamily: 'Inter',
                      color: const Color.fromARGB(255, 209, 22, 22),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // Numeric keypad
              _buildKeypad(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (_) => PinScreen()),
                      );
                    },
                    child: Text(
                      "Enter PIN",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SignInOptionsScreen()),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    List<List<String>> keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['←', '0', '✓'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildKey(key),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKey(String key) {
    IconData? icon;
    VoidCallback? onTap;

    if (key == '←') {
      icon = Icons.backspace_outlined;
      onTap = _onBackspace;
    } else if (key == '✓') {
      icon = Icons.check;
      onTap = _onSubmit;
    } else {
      onTap = () => _onNumberTap(key);
    }

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressedKey = key);
      },
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 20), () {
          setState(() => _pressedKey = null);
        });
        onTap?.call();
      },
      onTapCancel: () {
        setState(() => _pressedKey = null);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 20),
        curve: Curves.easeOut,
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _pressedKey == key
              ? Colors.white.withOpacity(0.1)
              : Colors.transparent,
          boxShadow: _pressedKey == key
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0),
                    blurRadius: 5,
                    spreadRadius: 0.5,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 28)
              : Text(
                  key,
                  style: TextStyle( fontFamily: 'Inter',
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _handleSwitchAccount(BuildContext context) async {
    try {
      // Sign out from Google
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      // Sign out from Facebook
      await FacebookAuth.instance.logOut();

      // Sign out from Firebase (covers email/password + phone)
      await FirebaseAuth.instance.signOut();

      // Remove temp data if any
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('temp_user_data');

      // Clear PIN for the current account
      final account = await LocalStorageService.getAccountIdentifier();
      if (account != null) {
        await LocalStorageService.clearPin(account);
      }

      // Clear account info + login flags
      await LocalStorageService.clearUserData();

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInOptionsScreen()),
        );
      }
    } catch (e) {
      print('Error switching account: $e');
    }
  } 
}
