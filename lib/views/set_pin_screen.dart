import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarisync/views/home.dart';
import 'package:sarisync/services/local_storage_service.dart';
import 'pin_screen.dart';

class SetPinScreen extends StatefulWidget {
  final String? accountIdentifier; // Can be phone, email, or any account identifier
  final String? accountType; // 'phone', 'google', 'facebook', etc.
  
  const SetPinScreen({super.key, this.accountIdentifier, this.accountType});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
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
    // Try to get account info from widget parameters first, then from storage
    String? account = widget.accountIdentifier ?? await LocalStorageService.getAccountIdentifier();
    String? type = widget.accountType ?? await LocalStorageService.getAccountType();
    
    setState(() {
      _displayAccount = account;
      _accountType = type;
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

              const SizedBox(height: 20),

              // Tagline
              Text(
                "Your Store. Smarter than ever.",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 30),

              // Account display (phone, email, or social media account)
              if (_displayAccount != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
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
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          _displayAccount!,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: const Color(0xFF1E88E5),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.swap_horiz,
                        color: const Color(0xFF1E88E5),
                        size: 24,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              // Set PIN text
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
                      color: const Color.fromARGB(255, 209, 22, 22),
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
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}