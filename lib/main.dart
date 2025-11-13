import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
//import 'dart:io'; // For File (if needed for image picking)
//import 'package:image_picker/image_picker.dart'; // Image picker

// Firebase options file (from flutterfire CLI)
import 'firebase_options.dart';

// Your pages
import 'views/pin_screen.dart';
import 'views/home.dart';
import 'views/inventory.dart';

// Your models
//import 'models/inventory_item.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // if (kDebugMode) {
  //   const host = '10.0.2.2';
  //   FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  //   FirebaseAuth.instance.useAuthEmulator(host, 9099);
  //   FirebaseStorage.instance.useStorageEmulator(host, 9199);
  // }

  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  
  if (kDebugMode) {
    print("Running in Debug mode");
  } else if (kReleaseMode) {
    print("Running in Release mode");
  } else if (kProfileMode) {
    print("Running in Profile mode");
  }


  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //hides the DEBUG banner
      title: 'SariSync',
      theme: ThemeData(
        fontFamily: GoogleFonts.inter().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFCFCFC)),
        useMaterial3: true,
      ),
      // Set the home to the initial splash screen
      home: SplashFrames(),
      //routes to other pages
      routes: {
        '/home': (context) => HomePage(),
        '/inventory': (context) => InventoryPage(),
        // Add these when you create the pages
        // '/ledger': (context) => LedgerPage(),
        // '/history': (context) => HistoryPage(),
      },
    );
  }
}

// ---------------------- SPLASH SCREEN ----------------------
class SplashFrames extends StatefulWidget {
  const SplashFrames({super.key});

  @override
  _SplashFramesState createState() => _SplashFramesState();
}

class _SplashFramesState extends State<SplashFrames> {
  double size = 36;
  double triangleHeight = 36;
  bool showTriangle = false;
  bool showLogo = false;
  bool phaseFourActive = false;
  int textLength = 0;
  final String textToDisplay = "SariSync";

  static const String backgroundAsset = 'assets/images/background.png';
  static const double logoSize = 48.0;

  @override
  void initState() {
    super.initState();

    // Phase 2: Show triangle & scale
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      setState(() {
        showTriangle = true;
        triangleHeight = 60;
        size = 60;
      });
    });

    // Phase 2.5: Show logo
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        showLogo = true;
      });
    });

    // Phase 3: Scale back down
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      setState(() {
        size = 36;
        triangleHeight = 20;
      });
    });

    // Phase 4: Slide left & start text animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() {
        phaseFourActive = true;
      });
      _startTextAnimation();
    });

    // Phase 5: Navigate to PIN screen
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PinScreen()),
        );
      }
    });
  }



  // Helper function for the letter-by-letter text appearance
  void _startTextAnimation() {
    int totalLetters = textToDisplay.length;
    const int delayPerLetterMs = 50;

    for (int i = 1; i <= totalLetters; i++) {
      Future.delayed(Duration(milliseconds: i * delayPerLetterMs), () {
        if (mounted) {
          setState(() {
            textLength = i;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 4.0;
    const double stackHeight = 180.0;
    const double stackWidth = 120.0;
    const double logoSlideDistance = 40.0;
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

        // Logo + Text
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

        // Shapes stack (square + triangle)
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
                          : stackHeight + 20.0,
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
