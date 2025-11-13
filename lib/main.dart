// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; // Ensure this file exists for Firebase setup
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// //pages
// import 'pin_screen.dart';
// import 'home.dart';
// import 'ledger.dart';
// import 'inventory.dart';
// import 'login_page.dart';

// // Initializing Firebase
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false, //hides the DEBUG banner
//       title: 'SariSync',
//       theme: ThemeData(
//         fontFamily: GoogleFonts.inter().fontFamily,
//         colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFCFCFC)),
//         useMaterial3: true,
//       ),
//       // Set the home to the initial splash screen
//       home: SplashFrames(),
//       //routes to other pages
//       routes: {
//         '/home': (context) => HomePage(),
//         '/inventory': (context) => InventoryPage(),
//         // Add these when you create the pages
//         '/ledger': (context) => LedgerPage(),
//         // '/history': (context) => HistoryPage(),
//       },
//     );
//   }
// }

// // for splash screen
// class SplashFrames extends StatefulWidget {
//   @override
//   _SplashFramesState createState() => _SplashFramesState();
// }

// class _SplashFramesState extends State<SplashFrames> {
//   // Animation State Variables (Phase 1-3)
//   double size = 36;
//   double triangleHeight = 30; //36
//   bool showTriangle = false;
//   Color backgroundColor = Colors.black;
//   bool showLogo = false;

//   // Phase 4 Variables
//   bool phaseFourActive = false; // Triggers slide-left movement
//   int textLength = 0; // Controls letter-by-letter appearance
//   final String textToDisplay = "SariSync";

//   // Asset Constants
//   static const String backgroundAsset = 'assets/images/background.png';
//   static const double logoSize =
//       48.0; // Adjusted logo size for better visibility

//   @override
//   void initState() {
//     super.initState();

//     // Phase 1: Initial state (36px square shown for 300ms is implicit)

//     // Phase 2: Triangle appears + scale up (Starts at 1300ms)
//     Future.delayed(const Duration(milliseconds: 1300), () {
//       if (!mounted) return;
//       setState(() {
//         showTriangle = true;
//         triangleHeight = 60;
//         size = 60;
//       });
//     });

//     // Phase 2.5: Background transition and logo appearance (Starts at 1600ms)
//     Future.delayed(const Duration(milliseconds: 1600), () {
//       if (!mounted) return;
//       setState(() {
//         showLogo = true;
//         // backgroundColor = const Color(0xFF2284C8);
//       });
//     });

//     // Phase 3: Scale back down (Starts at 1700ms - avoids conflict with 2.5 start)
//     Future.delayed(const Duration(milliseconds: 1700), () {
//       if (!mounted) return;
//       setState(() {
//         size = 36;
//         triangleHeight = 20;
//       });
//     });

//     // Phase 4: Exit Animation (Starts at 2000ms, giving 300ms for Phase 3)
//     Future.delayed(const Duration(milliseconds: 2000), () {
//       if (!mounted) return;
//       setState(() {
//         phaseFourActive = true; // Initiate slide-left
//       });
//       _startTextAnimation(); // Start the letter-by-letter animation
//     });

//     // Phase 5: Enter PIN
//     Future.delayed(const Duration(milliseconds: 3000), () {
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const LoginPage()),
//         );
//       }
//     });
//   }



//   // Helper function for the letter-by-letter text appearance
//   void _startTextAnimation() {
//     int totalLetters = textToDisplay.length;
//     const int delayPerLetterMs = 50;

//     // Start text animation slightly delayed after Phase 4 movement begins
//     Future.delayed(const Duration(milliseconds: 50), () {
//       for (int i = 1; i <= totalLetters; i++) {
//         Future.delayed(Duration(milliseconds: i * delayPerLetterMs), () {
//           if (mounted) {
//             setState(() {
//               textLength = i;
//             });
//           }
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     const double spacing = 4.0;
//     const double stackHeight = 180.0;
//     const double stackCenter = stackHeight / 2;
//     const double stackWidth = 120.0; // Width of the shapes stack

//     // Phase 4 Animation Variables
//     const double logoSlideDistance = 40.0; // Final resting position offset
//     const Duration exitDuration = Duration(milliseconds: 500);

//     // Dynamic animation values
//     final double logoLeftOffset = phaseFourActive ? logoSlideDistance : 0.0;
//     final double shapeOpacity = phaseFourActive ? 0.0 : 1.0;

//     // Root Stack to handle the full-screen background and central animation
//     return Stack(
//       children: [
//         // 1. Full-Screen Animated Background Container
//         AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           color: backgroundColor,
//           child: AnimatedOpacity(
//             opacity: showLogo ? 1.0 : 0.0,
//             duration: const Duration(milliseconds: 300),
//             child: Image.asset(
//               backgroundAsset,
//               fit: BoxFit.fill,
//               width: double.infinity,
//               height: double.infinity,
//             ),
//           ),
//         ),

//         // 2. Centered Logo and Text (Combined in a Row, sliding left)
//         Center(
//           child: AnimatedContainer(
//             duration: exitDuration,
//             // Slides the content left by adjusting the margin
//             margin: EdgeInsets.only(left: logoLeftOffset),
//             child: AnimatedOpacity(
//               opacity: showLogo ? 1.0 : 0.0,
//               duration: const Duration(milliseconds: 300),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min, // Keep the row compact
//                 children: [
//                   // Logo Image
//                   SizedBox(
//                     width: logoSize,
//                     height: logoSize,
//                     child: Image.asset('assets/images/logo.png'),
//                   ),

//                   // Text Beside the Logo (Letter-by-letter)
//                   if (showLogo)
//                     Padding(
//                       padding: const EdgeInsets.only(left: 5.0),
//                       child: Text(
//                         // Display substring based on textLength
//                         textToDisplay.substring(0, textLength),
//                         style: const TextStyle(
//                           fontFamily: 'Inter',
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),

//         // 3. Central Animation Stack (Shapes: Sliding and Fading Out)
//         Center(
//           child: AnimatedOpacity(
//             opacity: shapeOpacity, // Phase 4 fade out
//             duration: exitDuration,
//             child: AnimatedContainer(
//               duration: exitDuration,
//               curve: Curves.easeIn,
//               // SLIDE: Move off-screen to the left (by adding right padding)
//               padding: EdgeInsets.only(
//                 right: phaseFourActive ? stackWidth + 20.0 : 0.0,
//               ),
//               child: SizedBox(
//                 width: stackWidth,
//                 height: stackHeight,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // Square (base)
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                       width: size,
//                       height: size,
//                       color: Colors.blue,
//                     ),

//                     // Triangle (roof)
//                     AnimatedPositioned(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                       // Positioning formula based on size and height
//                       top: showTriangle
//                           ? (stackHeight / 2) -
//                                 (size / 2) -
//                                 triangleHeight -
//                                 spacing
//                           : stackHeight + 20.0,

//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                         width: size,
//                         height: triangleHeight,
//                         child: CustomPaint(painter: TrianglePainter()),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // for the triangle icon in the splash screen
// class TrianglePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = Colors.blue;
//     final path = Path()
//       ..moveTo(size.width / 2, 0)
//       ..lineTo(0, size.height)
//       ..lineTo(size.width, size.height)
//       ..close();
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }

// // // import 'package:flutter/material.dart';
// // // import 'package:firebase_core/firebase_core.dart';
// // // import 'firebase_options.dart'; // Ensure this file exists for Firebase setup
// // // import 'package:google_fonts/google_fonts.dart';

// // // //pages
// // // import 'pin_screen.dart';
// // // import 'home.dart';
// // // import 'ledger.dart';

// // // // Initializing Firebase
// // // Future<void> main() async {
// // //   WidgetsFlutterBinding.ensureInitialized();

// // //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

// // //   runApp(const MyApp());
// // // }

// // // class MyApp extends StatelessWidget {
// // //   const MyApp({super.key});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       debugShowCheckedModeBanner: false, //hides the DEBUG banner
// // //       title: 'Flutter Demo',
// // //       theme: ThemeData(
// // //         colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFCFCFC)),
// // //         useMaterial3: true,
// // //         textTheme: GoogleFonts.interTextTheme(),
// // //       ),
// // //       // Set the home to the initial splash screen
// // //       home: SplashFrames(),
// // //     );
// // //   }
// // // }

// // // // for splash screen
// // // class SplashFrames extends StatefulWidget {
// // //   @override
// // //   _SplashFramesState createState() => _SplashFramesState();
// // // }

// // // class _SplashFramesState extends State<SplashFrames> {
// // //   // Animation State Variables (Phase 1-3)
// // //   double size = 36;
// // //   double triangleHeight = 36; //36
// // //   bool showTriangle = false;
// // //   Color backgroundColor = Colors.black;
// // //   bool showLogo = false;

// // //   // Phase 4 Variables
// // //   bool phaseFourActive = false; // Triggers slide-left movement
// // //   int textLength = 0; // Controls letter-by-letter appearance
// // //   final String textToDisplay = "SariSync";

// // //   // Asset Constants
// // //   static const String backgroundAsset = 'assets/images/background.png';
// // //   static const double logoSize =
// // //       80; // Adjusted logo size for better visibility

// // //   @override
// // //   void initState() {
// // //     super.initState();

// // //     // Phase 1: Initial state (36px square shown for 300ms is implicit)

// // //     // Phase 2: Triangle appears + scale up (Starts at 1300ms)
// // //     Future.delayed(const Duration(milliseconds: 600), () {
// // //       if (!mounted) return;
// // //       setState(() {
// // //         showTriangle = true;
// // //         triangleHeight = 40;
// // //         size = 60;
// // //       });
// // //     });

// // //     // Phase 2.5: Background transition and logo appearance (Starts at 1600ms)
// // //     Future.delayed(const Duration(milliseconds: 1000), () {
// // //       if (!mounted) return;
// // //       setState(() {
// // //         showLogo = true;
// // //         // backgroundColor = const Color(0xFF2284C8);
// // //       });
// // //     });

// // //     // Phase 3: Scale back down (Starts at 1700ms - avoids conflict with 2.5 start)
// // //     Future.delayed(const Duration(milliseconds: 1100), () {
// // //       if (!mounted) return;
// // //       setState(() {
// // //         size = 36;
// // //         triangleHeight = 20;
// // //       });
// // //     });

// // //     // Phase 4: Exit Animation (Starts at 2000ms, giving 300ms for Phase 3)
// // //     Future.delayed(const Duration(milliseconds: 1400), () {
// // //       if (!mounted) return;
// // //       setState(() {
// // //         phaseFourActive = true; // Initiate slide-left
// // //       });
// // //       _startTextAnimation(); // Start the letter-by-letter animation
// // //     });

// // //     // Phase 5: Enter PIN
// // //     Future.delayed(const Duration(milliseconds: 3000), () {
// // //       if (mounted) {
// // //         Navigator.pushReplacement(
// // //           context,
// // //           MaterialPageRoute(builder: (context) => const PinScreen()),
// // //         );
// // //       }
// // //     });
// // //   }

// // //   // Helper function for the letter-by-letter text appearance
// // //   void _startTextAnimation() {
// // //     int totalLetters = textToDisplay.length;
// // //     const int delayPerLetterMs = 45;

// // //     // Start text animation slightly delayed after Phase 4 movement begins
// // //     Future.delayed(const Duration(milliseconds: 50), () {
// // //       for (int i = 1; i <= totalLetters; i++) {
// // //         Future.delayed(Duration(milliseconds: i * delayPerLetterMs), () {
// // //           if (mounted) {
// // //             setState(() {
// // //               textLength = i;
// // //             });
// // //           }
// // //         });
// // //       }
// // //     });
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     const double spacing = 4.0;
// // //     const double stackHeight = 180.0;
// // //     const double stackCenter = stackHeight / 2;
// // //     const double stackWidth = 120.0; // Width of the shapes stack

// // //     // Phase 4 Animation Variables
// // //     const double logoSlideDistance = 50.0; // Final resting position offset
// // //     const Duration exitDuration = Duration(milliseconds: 500);

// // //     // Dynamic animation values
// // //     final double logoLeftOffset = phaseFourActive ? logoSlideDistance : 0.0;
// // //     final double shapeOpacity = phaseFourActive ? 0.0 : 1.0;

// // //     // Root Stack to handle the full-screen background and central animation
// // //     return Stack(
// // //       children: [
// // //         // 1. Full-Screen Animated Background Container
// // //         AnimatedContainer(
// // //           duration: const Duration(milliseconds: 300),
// // //           color: backgroundColor,
// // //           child: AnimatedOpacity(
// // //             opacity: showLogo ? 1.0 : 0.0,
// // //             duration: const Duration(milliseconds: 300),
// // //             child: Image.asset(
// // //               backgroundAsset,
// // //               fit: BoxFit.fill,
// // //               width: double.infinity,
// // //               height: double.infinity,
// // //             ),
// // //           ),
// // //         ),

// // //         // 2. Centered Logo and Text (Combined in a Row, sliding left)
// // //         Center(
// // //           child: AnimatedContainer(
// // //             duration: exitDuration,
// // //             // Slides the content left by adjusting the margin
// // //             margin: EdgeInsets.only(left: logoLeftOffset),
// // //             child: AnimatedOpacity(
// // //               opacity: showLogo ? 1.0 : 0.0,
// // //               duration: const Duration(milliseconds: 300),
// // //               child: Row(
// // //                 mainAxisSize: MainAxisSize.min, // Keep the row compact
// // //                 children: [
// // //                   // Logo Image
// // //                   SizedBox(
// // //                     width: logoSize,
// // //                     height: logoSize,
// // //                     child: Image.asset('assets/images/logo.png'),
// // //                   ),

// // //                   // Text Beside the Logo (Letter-by-letter)
// // //                   if (showLogo)
// // //                     Padding(
// // //                       padding: const EdgeInsets.only(left: 5.0),
// // //                       child: Text(
// // //                         // Display substring based on textLength
// // //                         textToDisplay.substring(0, textLength),
// // //                         style: const TextStyle(
// // //                           fontFamily: 'Inter',
// // //                           fontSize: 32,
// // //                           fontWeight: FontWeight.bold,
// // //                           color: Colors.white,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         ),

// // //         // 3. Central Animation Stack (Shapes: Sliding and Fading Out)
// // //         Center(
// // //           child: AnimatedOpacity(
// // //             opacity: shapeOpacity, // Phase 4 fade out
// // //             duration: exitDuration,
// // //             child: AnimatedContainer(
// // //               duration: exitDuration,
// // //               curve: Curves.easeIn,
// // //               // SLIDE: Move off-screen to the left (by adding right padding)
// // //               padding: EdgeInsets.only(
// // //                 right: phaseFourActive ? stackWidth + 20.0 : 0.0,
// // //               ),
// // //               child: SizedBox(
// // //                 width: stackWidth,
// // //                 height: stackHeight,
// // //                 child: Stack(
// // //                   alignment: Alignment.center,
// // //                   children: [
// // //                     // Square (base)
// // //                     AnimatedContainer(
// // //                       duration: const Duration(milliseconds: 300),
// // //                       curve: Curves.easeInOut,
// // //                       width: size,
// // //                       height: size,
// // //                       color: Colors.blue,
// // //                     ),

// // //                     // Triangle (roof)
// // //                     AnimatedPositioned(
// // //                       duration: const Duration(milliseconds: 300),
// // //                       curve: Curves.easeInOut,
// // //                       // Positioning formula based on size and height
// // //                       top: showTriangle
// // //                           ? (stackHeight / 2) -
// // //                                 (size / 2) -
// // //                                 triangleHeight -
// // //                                 spacing
// // //                           : stackHeight + 20.0,

// // //                       child: AnimatedContainer(
// // //                         duration: const Duration(milliseconds: 300),
// // //                         curve: Curves.easeInOut,
// // //                         width: size,
// // //                         height: triangleHeight,
// // //                         child: CustomPaint(painter: TrianglePainter()),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // // }

// // // // for the triangle icon in the splash screen
// // // class TrianglePainter extends CustomPainter {
// // //   @override
// // //   void paint(Canvas canvas, Size size) {
// // //     final paint = Paint()..color = Colors.blue;
// // //     final path = Path()
// // //       ..moveTo(size.width / 2, 0)
// // //       ..lineTo(0, size.height)
// // //       ..lineTo(size.width, size.height)
// // //       ..close();
// // //     canvas.drawPath(path, paint);
// // //   }

// // //   @override
// // //   bool shouldRepaint(CustomPainter oldDelegate) => false;
// // // }

// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'firebase_options.dart'; // Firebase setup file
// // import 'pin_screen.dart'; // Target after splash

// // Future<void> main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       title: 'SariSync',
// //       theme: ThemeData(
// //         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFCFCFC)),
// //         useMaterial3: true,
// //       ),
// //       home: const SplashFrames(),
// //     );
// //   }
// // }

// // // 🌊 SPLASH SCREEN WITH ANIMATION
// // class SplashFrames extends StatefulWidget {
// //   const SplashFrames({super.key});

// //   @override
// //   State<SplashFrames> createState() => _SplashFramesState();
// // }

// // class _SplashFramesState extends State<SplashFrames>
// //     with TickerProviderStateMixin {
// //   // Animation state variables
// //   double size = 36;
// //   double triangleHeight = 36;
// //   bool showTriangle = false;
// //   bool showLogo = false;
// //   bool phaseFourActive = false;
// //   int textLength = 0;

// //   static const String textToDisplay = "SariSync";
// //   final Color backgroundColor = Colors.black;
// //   static const String backgroundAsset = 'assets/images/background.png';
// //   static const double logoSize = 80;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _runAnimationSequence();
// //   }

// //   // 🧩 Runs the animation step by step in sequence
// //   void _runAnimationSequence() async {
// //     // Phase 1: Pause shortly (for base square)
// //     await Future.delayed(const Duration(milliseconds: 400));

// //     // Phase 2: Show triangle + scale up
// //     if (mounted) {
// //       setState(() {
// //         showTriangle = true;
// //         triangleHeight = 45;
// //         size = 60;
// //       });
// //     }

// //     await Future.delayed(const Duration(milliseconds: 400));

// //     // Phase 3: Show logo + fade in background
// //     if (mounted) {
// //       setState(() {
// //         showLogo = true;
// //       });
// //     }

// //     await Future.delayed(const Duration(milliseconds: 300));

// //     // Phase 4: Shrink square + triangle
// //     if (mounted) {
// //       setState(() {
// //         size = 36;
// //         triangleHeight = 20;
// //       });
// //     }

// //     await Future.delayed(const Duration(milliseconds: 400));

// //     // Phase 5: Slide left + start text animation
// //     if (mounted) {
// //       setState(() => phaseFourActive = true);
// //       _startTextAnimation();
// //     }

// //     // Wait before navigating to next page
// //     await Future.delayed(const Duration(milliseconds: 2600));

// //     if (mounted) {
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (_) => const PinScreen()),
// //       );
// //     }
// //   }

// //   // 🪶 Text reveal animation
// //   void _startTextAnimation() {
// //     const delayPerLetter = 50;
// //     for (int i = 1; i <= textToDisplay.length; i++) {
// //       Future.delayed(Duration(milliseconds: i * delayPerLetter), () {
// //         if (mounted) {
// //           setState(() => textLength = i);
// //         }
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     const double spacing = 4.0;
// //     const double stackHeight = 180.0;
// //     const double stackWidth = 120.0;
// //     const double logoSlideDistance = 50.0;
// //     const Duration exitDuration = Duration(milliseconds: 600);

// //     // Animated values
// //     final double logoLeftOffset = phaseFourActive ? logoSlideDistance : 0.0;
// //     final double shapeOpacity = phaseFourActive ? 0.0 : 1.0;

// //     return Stack(
// //       children: [
// //         // 🌌 Animated background
// //         AnimatedContainer(
// //           duration: const Duration(milliseconds: 500),
// //           curve: Curves.easeOutCubic,
// //           color: backgroundColor,
// //           child: AnimatedOpacity(
// //             opacity: showLogo ? 1.0 : 0.0,
// //             duration: const Duration(milliseconds: 500),
// //             child: Image.asset(
// //               backgroundAsset,
// //               fit: BoxFit.fill,
// //               width: double.infinity,
// //               height: double.infinity,
// //             ),
// //           ),
// //         ),

// //         // 🏷️ Logo and text that slide left
// //         Center(
// //           child: AnimatedContainer(
// //             duration: exitDuration,
// //             curve: Curves.easeOutCubic,
// //             margin: EdgeInsets.only(left: logoLeftOffset),
// //             child: AnimatedOpacity(
// //               opacity: showLogo ? 1.0 : 0.0,
// //               duration: const Duration(milliseconds: 500),
// //               curve: Curves.easeOut,
// //               child: Row(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   // Logo image
// //                   AnimatedScale(
// //                     scale: showLogo ? 1.0 : 0.8,
// //                     duration: const Duration(milliseconds: 400),
// //                     curve: Curves.easeOutBack,
// //                     child: Image.asset(
// //                       'assets/images/logo.png',
// //                       width: logoSize,
// //                       height: logoSize,
// //                     ),
// //                   ),
// //                   // Text (revealed letter by letter)
// //                   if (showLogo)
// //                     Padding(
// //                       padding: const EdgeInsets.only(left: 8.0),
// //                       child: Text(
// //                         textToDisplay.substring(0, textLength),
// //                         style: const TextStyle(
// //                           fontFamily: 'Inter',
// //                           fontSize: 32,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                     ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),

// //         // 🔷 Square and Triangle (center animation)
// //         Center(
// //           child: AnimatedOpacity(
// //             opacity: shapeOpacity,
// //             duration: exitDuration,
// //             child: AnimatedContainer(
// //               duration: exitDuration,
// //               curve: Curves.easeInOut,
// //               padding: EdgeInsets.only(
// //                 right: phaseFourActive ? stackWidth + 30.0 : 0.0,
// //               ),
// //               child: SizedBox(
// //                 width: stackWidth,
// //                 height: stackHeight,
// //                 child: Stack(
// //                   alignment: Alignment.center,
// //                   children: [
// //                     // Square
// //                     AnimatedContainer(
// //                       duration: const Duration(milliseconds: 400),
// //                       curve: Curves.easeOutCubic,
// //                       width: size,
// //                       height: size,
// //                       decoration: BoxDecoration(
// //                         color: Colors.blue,
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                     ),
// //                     // Triangle (roof)
// //                     AnimatedPositioned(
// //                       duration: const Duration(milliseconds: 400),
// //                       curve: Curves.easeOutCubic,
// //                       top: showTriangle
// //                           ? (stackHeight / 2) -
// //                                 (size / 2) -
// //                                 triangleHeight -
// //                                 spacing
// //                           : stackHeight + 20.0,
// //                       child: AnimatedContainer(
// //                         duration: const Duration(milliseconds: 400),
// //                         curve: Curves.easeOutCubic,
// //                         width: size,
// //                         height: triangleHeight,
// //                         child: CustomPaint(painter: TrianglePainter()),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // // Triangle Painter
// // class TrianglePainter extends CustomPainter {
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final paint = Paint()..color = Colors.blueAccent;
// //     final path = Path()
// //       ..moveTo(size.width / 2, 0)
// //       ..lineTo(0, size.height)
// //       ..lineTo(size.width, size.height)
// //       ..close();
// //     canvas.drawPath(path, paint);
// //   }

// //   @override
// //   bool shouldRepaint(CustomPainter oldDelegate) => false;
// // }


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Generated by FlutterFire CLI
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Pages
import 'pin_screen.dart';
import 'home.dart';
import 'ledger.dart';
import 'inventory.dart';
import 'login_page.dart'; // Your separate login page

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SariSync',
      theme: ThemeData(
        fontFamily: GoogleFonts.inter().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFCFCFC)),
        useMaterial3: true,
      ),
      home: const SplashFrames(),
      routes: {
        '/home': (context) => HomePage(),
        '/inventory': (context) => InventoryPage(),
        '/ledger': (context) => LedgerPage(),
        '/pin': (context) => const PinScreen(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class SplashFrames extends StatefulWidget {
  const SplashFrames({super.key});

  @override
  State<SplashFrames> createState() => _SplashFramesState();
}

class _SplashFramesState extends State<SplashFrames> {
  // Animation state variables
  double size = 36;
  double triangleHeight = 30;
  bool showTriangle = false;
  bool showLogo = false;
  bool phaseFourActive = false;
  int textLength = 0;
  final String textToDisplay = "SariSync";

  static const String backgroundAsset = 'assets/images/background.png';
  static const double logoSize = 48;

  @override
  void initState() {
    super.initState();
    _startAnimationSequence();
  }

  void _startAnimationSequence() {
    // Phase 1-3 animations
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      setState(() {
        showTriangle = true;
        triangleHeight = 60;
        size = 60;
      });
    });

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        showLogo = true;
      });
    });

    Future.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      setState(() {
        size = 36;
        triangleHeight = 20;
      });
    });

    // Phase 4: slide left + start text animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() {
        phaseFourActive = true;
      });
      _startTextAnimation();
    });

    // Phase 5: navigate to login or PIN
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/pin');
      }
    });
  }

  void _startTextAnimation() {
    for (int i = 1; i <= textToDisplay.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (!mounted) return;
        setState(() {
          textLength = i;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double stackHeight = 180;
    const double stackWidth = 120;
    const double spacing = 4;
    const double logoSlideDistance = 40;
    const Duration exitDuration = Duration(milliseconds: 500);

    final double logoLeftOffset = phaseFourActive ? logoSlideDistance : 0.0;
    final double shapeOpacity = phaseFourActive ? 0.0 : 1.0;

    return Stack(
      children: [
        // Background
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: Colors.black,
          child: AnimatedOpacity(
            opacity: showLogo ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Image.asset(
              backgroundAsset,
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        // Logo and text
        Center(
          child: AnimatedContainer(
            duration: exitDuration,
            margin: EdgeInsets.only(left: logoLeftOffset),
            child: AnimatedOpacity(
              opacity: showLogo ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                  if (showLogo)
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        textToDisplay.substring(0, textLength),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Center shapes
        Center(
          child: AnimatedOpacity(
            opacity: shapeOpacity,
            duration: exitDuration,
            child: AnimatedContainer(
              duration: exitDuration,
              curve: Curves.easeIn,
              padding: EdgeInsets.only(
                right: phaseFourActive ? stackWidth + 20.0 : 0.0,
              ),
              child: SizedBox(
                width: stackWidth,
                height: stackHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: size,
                      height: size,
                      color: Colors.blue,
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      top: showTriangle
                          ? (stackHeight / 2) - (size / 2) - triangleHeight - spacing
                          : stackHeight + 20,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: size,
                        height: triangleHeight,
                        child: CustomPaint(painter: TrianglePainter()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Triangle Painter
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
