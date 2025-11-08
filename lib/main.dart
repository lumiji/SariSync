import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure this file exists for Firebase setup
import 'package:google_fonts/google_fonts.dart';
import 'pin_screen.dart';

// Initializing Firebase
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Set the home to the initial splash screen
      home: SplashFrames(),
    );
  }
}

// for splash screen
class SplashFrames extends StatefulWidget {
  @override
  _SplashFramesState createState() => _SplashFramesState();
}

class _SplashFramesState extends State<SplashFrames> {
  // Animation State Variables (Phase 1-3)
  double size = 36;
  double triangleHeight = 36;
  bool showTriangle = false;
  Color backgroundColor = Colors.black;
  bool showLogo = false;

  // Phase 4 Variables
  bool phaseFourActive = false; // Triggers slide-left movement
  int textLength = 0; // Controls letter-by-letter appearance
  final String textToDisplay = "SariSync";

  // Asset Constants
  static const String backgroundAsset = 'assets/images/background.png';
  static const double logoSize =
      48.0; // Adjusted logo size for better visibility

  @override
  void initState() {
    super.initState();

    // Phase 1: Initial state (36px square shown for 300ms is implicit)

    // Phase 2: Triangle appears + scale up (Starts at 1300ms)
    Future.delayed(const Duration(milliseconds: 1300), () {
      setState(() {
        showTriangle = true;
        triangleHeight = 60;
        size = 60;
      });
    });

    // Phase 2.5: Background transition and logo appearance (Starts at 1600ms)
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        showLogo = true;
        // backgroundColor = const Color(0xFF2284C8);
      });
    });

    // Phase 3: Scale back down (Starts at 1700ms - avoids conflict with 2.5 start)
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      setState(() {
        size = 36;
        triangleHeight = 20;
      });
    });

    // Phase 4: Exit Animation (Starts at 2000ms, giving 300ms for Phase 3)
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() {
        phaseFourActive = true; // Initiate slide-left
      });
      _startTextAnimation(); // Start the letter-by-letter animation
    });

    // Phase 5: Enter PIN
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

    // Start text animation slightly delayed after Phase 4 movement begins
    Future.delayed(const Duration(milliseconds: 50), () {
      for (int i = 1; i <= totalLetters; i++) {
        Future.delayed(Duration(milliseconds: i * delayPerLetterMs), () {
          if (mounted) {
            setState(() {
              textLength = i;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 4.0;
    const double stackHeight = 180.0;
    const double stackCenter = stackHeight / 2;
    const double stackWidth = 120.0; // Width of the shapes stack

    // Phase 4 Animation Variables
    const double logoSlideDistance = 40.0; // Final resting position offset
    const Duration exitDuration = Duration(milliseconds: 500);

    // Dynamic animation values
    final double logoLeftOffset = phaseFourActive ? logoSlideDistance : 0.0;
    final double shapeOpacity = phaseFourActive ? 0.0 : 1.0;

    // Root Stack to handle the full-screen background and central animation
    return Stack(
      children: [
        // 1. Full-Screen Animated Background Container
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: backgroundColor,
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

        // 2. Centered Logo and Text (Combined in a Row, sliding left)
        Center(
          child: AnimatedContainer(
            duration: exitDuration,
            // Slides the content left by adjusting the margin
            margin: EdgeInsets.only(left: logoLeftOffset),
            child: AnimatedOpacity(
              opacity: showLogo ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Keep the row compact
                children: [
                  // Logo Image
                  SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: Image.asset('assets/images/logo.png'),
                  ),

                  // Text Beside the Logo (Letter-by-letter)
                  if (showLogo)
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        // Display substring based on textLength
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

        // 3. Central Animation Stack (Shapes: Sliding and Fading Out)
        Center(
          child: AnimatedOpacity(
            opacity: shapeOpacity, // Phase 4 fade out
            duration: exitDuration,
            child: AnimatedContainer(
              duration: exitDuration,
              curve: Curves.easeIn,
              // SLIDE: Move off-screen to the left (by adding right padding)
              padding: EdgeInsets.only(
                right: phaseFourActive ? stackWidth + 20.0 : 0.0,
              ),
              child: SizedBox(
                width: stackWidth,
                height: stackHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Square (base)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: size,
                      height: size,
                      color: Colors.blue,
                    ),

                    // Triangle (roof)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      // Positioning formula based on size and height
                      top: showTriangle
                          ? (stackHeight / 2) -
                                (size / 2) -
                                triangleHeight -
                                spacing
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

// for the triangle icon in the splash screen
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

// Main App Screen (Target of Navigation)
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
