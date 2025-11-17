import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/google_auth_service.dart';
import 'phone_sign_in_screen.dart';
import '../services/fb_auth_service.dart';
import 'pin_screen.dart';
import 'set_pin_screen.dart';
import 'package:sarisync/services/local_storage_service.dart';
import 'package:sarisync/services/auth_flow_service.dart';

class SignInOptionsScreen extends StatelessWidget {
  const SignInOptionsScreen({super.key});

  // Future<void> handlePostLogin(BuildContext context) async {
  //   // Mark user as logged in
  //   await LocalStorageService.saveLoggedIn();

  //   // Check if PIN exists
  //   String? pin = await LocalStorageService.getPin();

  //   if (pin == null || pin.isEmpty) {
  //     // NO PIN → go to Set PIN screen
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => SetPinScreen()),
  //     );
  //   } else {
  //     // HAS PIN → go to Enter PIN screen
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => PinScreen()),
  //     );
  //   }

  //   // Mark user as logged in (optional)
  //   await LocalStorageService.saveLoggedIn();

  // }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final fbService = FacebookAuthService();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1️⃣ MAIN BACKGROUND IMAGE
          Image.asset('assets/images/background.png', fit: BoxFit.cover),

          //Logo
          Positioned(
            top: 120, // adjust if you want it higher/lower
            left: 60, //112
            right: 0,
            child: Row(
              children: [
                Image.asset('assets/images/logo.png', width: 80, height: 80),
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

          //WHITE BACKGROUND PNG LAYER (BOTTOM SECTION)
          Positioned(
            top: 210, // where white bg starts
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/White_bg.png',
              width: MediaQuery.of(context).size.width,
              height: 655, // you can adjust this!
              fit: BoxFit.fill,
            ),
          ),

          //CONTENT (WELCOME + BUTTONS)
          Positioned(
            top: 380, // move this to adjust content position
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Welcome text
                Text(
                  "Welcome!",
                  style: GoogleFonts.inter(
                    fontSize: 40,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 45),

                // BUTTONS
                FractionallySizedBox(
                  widthFactor: 0.8, // buttons occupy 90% of screen width
                  child: Column(
                    children: [
                      // Google Sign-in
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),

                          shadowColor: Colors.black26,
                          elevation: 5,
                        ),
                        onPressed: () async {
                          final user = await authService.signInWithGoogle();

                          if (user != null) {
                            print(
                              "Signed in as ${user.displayName}, email: ${user.email}",
                            );

                            // await handlePostLogin(context); // ⭐ ADD THIS
                            await AuthFlowService.handlePostLogin(context);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 10),
                            Image.asset(
                              'assets/images/google_logo.png',
                              height: 24,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              "Continue with Google",
                              style: GoogleFonts.inter(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 17),

                      // Facebook
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1877F2),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async {
                          final user = await fbService.signInWithFacebook(
                            //forceLogin: true,
                          );

                          if (user != null) {
                            // Successfully signed in
                            print(
                              "Facebook user: ${user.displayName}, email: ${user.email}",
                            );

                            // await handlePostLogin(context); // ⭐ ADD THIS
                             await AuthFlowService.handlePostLogin(context);
                          } else {
                            // Login failed or cancelled
                            print("Facebook login not successful");
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.facebook,
                              color: Colors.white,
                              size: 25,
                            ),
                            const SizedBox(width: 20),
                            Text(
                              "Continue with Facebook",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 17),

                      // Phone
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PhoneSignInScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 25,
                            ),
                            const SizedBox(width: 20),
                            Text(
                              "Continue with Phone",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
        ],
      ),
    );
  }
}
