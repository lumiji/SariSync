import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sarisync/models/pending_registration.dart';
import '../services/google_auth_service.dart';
import 'phone_sign_in_screen.dart';
import '../services/fb_auth_service.dart';
import 'set_pin_screen.dart';
import 'package:sarisync/views/pin_screen.dart';
import 'package:sarisync/widgets/terms_and_conditions.dart';

class SignInOptionsScreen extends StatefulWidget {
  const SignInOptionsScreen({super.key});

  @override
  State<SignInOptionsScreen> createState() => _SignInOptionsScreenState();
}

class _SignInOptionsScreenState extends State<SignInOptionsScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

    bool _isValidEmail(String email) {
      return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    }
  

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final fbService = FacebookAuthService();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column (
             children: [

              const SizedBox(height: 100),
              // Logo + Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', width: 72, height: 72),
                  const SizedBox(width: 0),
                  Text(
                    "SariSync",
                    style: TextStyle( fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),


          FractionallySizedBox(
            widthFactor: 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Welcome text
                  Text(
                    "Create your account",
                    style: TextStyle( fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // INPUT FIELDS AND BUTTONS
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username Label
                        Text(
                          "Email",
                          style: TextStyle( fontFamily: 'Inter',
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),

                        // Username Input
                        TextField(
                          controller: _usernameController,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.person_outline, 
                              color: Colors.white70
                            ),
                            hintText: "e.g., Jane Doe",
                            hintStyle: TextStyle(
                              color: Colors.white38),
                            filled: false,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.zero,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.zero,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),

                        const SizedBox(height: 12),

                        // Email Label
                          Text(
                            "Email",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),

                          // Email Input
                          TextField(
                            controller: _emailController,
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Colors.white70,
                              ),
                              hintText: "your@email.com",
                              hintStyle: TextStyle(color: Colors.white38),
                              filled: false,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.zero,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.zero,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),

                          const SizedBox(height: 12),

                          // Password Label
                        Text(
                          "Password",
                          style: TextStyle( fontFamily: 'Inter',
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),

                        // Password Input
                        TextField(
                          controller: _passwordController,
                          cursorColor: Colors.white,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                            filled: false,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.zero,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.zero,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),

                        const SizedBox(height: 12),

                        // Confirm Password Label
                        Text(
                          "Confirm Password",
                          style: TextStyle( fontFamily: 'Inter',
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),

                        // Confirm Password Input
                        TextField(
                          controller: _confirmPasswordController,
                          cursorColor: Colors.white,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            filled: false,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.zero,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.zero,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),

                        const SizedBox(height: 24),

                        //create account button
                        FractionallySizedBox(
                          widthFactor: 1,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () async {
                              final username = _usernameController.text.trim();
                              final email = _emailController.text.trim();
                              final password = _passwordController.text.trim();
                              final confirmPassword = _confirmPasswordController.text.trim();

                              if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please fill all fields")),
                                );
                                return;
                              }
                               final accepted = await showTermsAndConditionsDialog(context: context);

                                if (!accepted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Please accept the Terms and Conditions"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }


                              if (!_isValidEmail(email)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Please enter a valid email address")),
                                  );
                                  return;
                                }

                              if (password != confirmPassword) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Passwords do not match")),
                                );
                                return;
                              }

                              if (password.length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Password must be at least 6 characters"
                                    )),
                                ); 
                                return;
                              }

                              try {
                              
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SetPinScreen(
                                      accountIdentifier: username,
                                      accountType: "password",
                                      pendingRegistration: PendingRegistration(
                                        email: email,
                                        password: password,
                                        accountType: "password",
                                        displayIdentifier: username),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              }
                            },
                            child: Text(
                              "Create Account",
                              style: TextStyle( fontFamily: 'Inter',
                                color: const Color(0xFF1565C0),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        
                        const SizedBox(height: 36),

                        // "Or sign up with" text
                        Center(
                          child: Text(
                            "-Or sign up with-",
                            style: TextStyle( fontFamily: 'Inter',
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Social Sign-in Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google Button
                            InkWell(
                              onTap: () async {

                                final accepted = await showTermsAndConditionsDialog(context: context);

                                if (!accepted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Please accept the Terms and Conditions"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }


                                final result = await authService.signInWithGoogleGetTokens();
                                if (result != null) {
                                  final displayIdentifier = result['displayName'] ?? result['email'] ?? '';

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SetPinScreen(
                                          accountIdentifier: displayIdentifier,
                                          accountType: "google",
                                          pendingRegistration: PendingRegistration(
                                            googleIdToken: result['idToken'],
                                            googleAccessToken: result['accessToken'],
                                            accountType: "google",
                                            displayIdentifier: displayIdentifier,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/google_logo.png',
                                    height: 24,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 32),

                            // Facebook Button
                            InkWell(
                              onTap: () async {

                                final accepted = await showTermsAndConditionsDialog(context: context);

                                if (!accepted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Please accept the Terms and Conditions"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }


                                final result = await fbService.signInWithFacebookGetTokens();
                                if (result != null) {

                                  final displayIdentifier = result['displayName'] ?? result['email'] ?? '';
                                
                                   Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SetPinScreen(
                                        accountIdentifier: displayIdentifier,
                                        accountType: "facebook",
                                        pendingRegistration: PendingRegistration(
                                          facebookAccessToken: result['accessToken'],
                                          accountType: "facebook",
                                          displayIdentifier: displayIdentifier,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  print("Facebook login not successful");
                                }
                              },
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.facebook,
                                    color: Color(0xFF1877F2),
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 32),

                            // Phone Button
                            InkWell(
                              onTap: () async {

                                 final accepted = await showTermsAndConditionsDialog(
                                    context: context,
                                  );

                                  if (!accepted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Please accept the Terms and Conditions"),
                                        backgroundColor: Color(0xFFE53935),
                                      ),
                                    );
                                    return;
                                  }
                              
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PhoneSignInScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.phone,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // "Already have an account? Log in" text
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Navigate to login screen
                              Navigator.push(context, MaterialPageRoute(builder: (_) => PinScreen()));
                            },
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle( fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                children: [
                                  TextSpan(text: "Already have an account? "),
                                  TextSpan(
                                    text: "Log in",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}