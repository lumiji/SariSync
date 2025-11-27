import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sarisync/views/home.dart';
import 'package:sarisync/services/local_storage_service.dart';
import 'package:sarisync/views/set_pin_screen.dart';
import 'package:sarisync/views/sign-in_options.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
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
    _displayAccount = await LocalStorageService.getAccountIdentifier();
    _accountType = await LocalStorageService.getAccountType();
    setState(() {});
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

//PIN input logic

  void _onNumberTap(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        if (_errorMessage.isNotEmpty) _errorMessage = '';
      });
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
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

    String? savedPin = await LocalStorageService.getPin();

    if (savedPin == null) {
      setState(() => _errorMessage = 'No PIN is set. Please set a PIN first.');
      return;
    }

    if (_enteredPin == savedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN';
        _enteredPin = '';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.png', fit: BoxFit.fill),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              //Logo + tagline
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
                      const SizedBox(width: 4),
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

              const SizedBox(height: 12),

              
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
                  margin: const EdgeInsets.symmetric(horizontal: 12),
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
                        onPressed: () {
                          // Navigate back to SignInOptionsScreen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const SignInOptionsScreen()),
                          );
                        },
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

              //Enter PIN
              Text(
                "Enter PIN",
                style: TextStyle( fontFamily: 'Inter',
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              //PIN Circles
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

              _buildKeypad(),

               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SetPinScreen()),
                      );
                    },
                    child: Text(
                      "Set PIN",
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
              )
            ],
          ),
        ],
      ),
    );
  }

//PIN keypads

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
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _pressedKey == key
              ? Colors.white.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 28)
              : Text(
                  key,
                  style: TextStyle( fontFamily: 'Inter',
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
