//Flutter dependencies
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

//Firebase dependencies
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage

//pages
import 'views/pin_screen.dart';
import 'views/home.dart';
import 'views/inventory.dart';

//models
//import 'models/inventory_item.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

  await Future.delayed(const Duration(seconds: 1));
  FlutterNativeSplash.remove();
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
      home: HomePage(),
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
