// import 'main.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarisync/main.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _enteredPin = '';
  String _errorMessage = '';
  List<String> _input = [];

  void _onNumberTap(String number) {
    //   if (_enteredPin.length < 4) {
    //     setState(() {
    //       _enteredPin += number;

    //             // Clear error if user starts typing again
    //     if (_errorMessage.isNotEmpty) _errorMessage = '';
    //     });
    //     if (_enteredPin.length == 4) {
    //       // ✅ Automatically go to home after entering 4 digits
    //       Future.delayed(const Duration(milliseconds: 300), () {
    //         Navigator.pushReplacement(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) => const MyHomePage(title: 'Home'),
    //           ),
    //         );
    //       });
    //     }
    //   }
    // }
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

  void _onSubmit() {
    //   if (_enteredPin.length == 4) {
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => const MyHomePage(title: 'Home'),
    //       ),
    //     );
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Please enter your 4-digit PIN')),
    //     );
    //   }
    // }
    setState(() {
      if (_enteredPin.length == 4) {
        _errorMessage = ''; // clear error
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'Home'),
          ),
        );
      } else {
        _errorMessage = 'Please enter all 4 digits';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ Background image with blur effect
          Image.asset('assets/images/background.png', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(color: Colors.blue.withOpacity(0.4)),
          ),

          // ✅ Content layout
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // Logo and text
              Column(
                children: [
                  Image.asset('assets/images/logo.png', width: 60, height: 60),
                  const SizedBox(height: 8),
                  Text(
                    "SariSync",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // "Enter PIN" label
              Text(
                "Enter PIN",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  color: Colors.white.withOpacity(1.0),
                ),
              ),
              const SizedBox(height: 20),

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
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  );
                }),
              ),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 54, 51, 51),
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.15),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 28)
              : Text(
                  key,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
