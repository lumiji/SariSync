import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarisync/home.dart';
import 'package:sarisync/services/local_storage_service.dart';
import 'pin_screen.dart';



class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String _enteredPin = '';
  String _errorMessage = '';
  // List<String> _input = [];
  String? _pressedKey;

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

  // void _onSubmit() {
  //   setState(() {
  //     if (_enteredPin.length == 4) {
  //       _errorMessage = ''; // clear error
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => HomePage()),
  //       );
  //     } else {
  //       _errorMessage = 'Enter 4 digits';
  //     }
  //   });
  // }


     void _onSubmit() async {
  if (_enteredPin.length == 4) {
    setState(() {
      _errorMessage = '';
    });

    // Save PIN locally
    await LocalStorageService.savePin(_enteredPin);

    // Mark user as logged in (first-time sign-in complete)
    await LocalStorageService.saveLoggedIn();

    // Redirect to enter PIN screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PinScreen()),
    );
  } else {
    setState(() {
      _errorMessage = 'Enter 4 digits';
    });
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
                  padding: const EdgeInsets.only(
                    top: 10,
                  ), // adjust between 60–100 as you like
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
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 75),

              Text(
                "Set PIN",
                style: GoogleFonts.inter(
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
                    style: GoogleFonts.inter(
                      color: Color.fromARGB(255, 209, 22, 22),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // Numeric keypad
              _buildKeypad(),
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
              ? Colors.white.withOpacity(0.1) // soft glow when pressed
              : Colors.transparent, // normal state
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
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
