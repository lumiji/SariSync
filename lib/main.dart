//Flutter dependencies
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

//Firebase dependencies
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore

//pages
import 'views/set_pin_screen.dart';
import 'views/pin_screen.dart';
import 'views/home.dart';
import 'views/ledger.dart';
import 'views/inventory.dart';
import 'views/sign-in_options.dart';

//models, widgets, & services
import 'services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED
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
      debugShowCheckedModeBanner: false,
      title: 'SariSync',
      theme: ThemeData(
        fontFamily: const TextStyle(fontFamily: 'Inter').fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFCFCFC)),
        useMaterial3: true,
      ),
      home: const ConnectivityWrapper(child: InitialNavigator()),
      routes: {
        '/home': (context) => const ConnectivityWrapper(child: HomePage()),
        '/inventory': (context) => const ConnectivityWrapper(child: InventoryPage()),
        '/ledger': (context) => const ConnectivityWrapper(child: LedgerPage()),
      },
    );
  }
}

// Wrapper widget that shows connectivity status banner
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _setupConnectivityListener();
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    
    setState(() {
      _isOnline = result.first != ConnectivityResult.none;
      _showBanner = !_isOnline;
    });
  }

  void _setupConnectivityListener() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      final nowOnline = result.first != ConnectivityResult.none;

      if (nowOnline != _isOnline) {
        setState(() {
          _isOnline = nowOnline;
          _showBanner = true;
        });

        if (_isOnline) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showBanner = false;
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showBanner ? 40 : 0,
          color: _isOnline ? Colors.green : Colors.orange[700],
          child: _showBanner
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isOnline ? Icons.wifi : Icons.wifi_off,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isOnline
                            ? 'Back online - syncing data...'
                            : 'No internet connection',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!_isOnline) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showBanner = false;
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : null,
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class InitialNavigator extends StatefulWidget {
  const InitialNavigator({super.key});

  @override
  State<InitialNavigator> createState() => _InitialNavigatorState();
}

class _InitialNavigatorState extends State<InitialNavigator> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() {
    Future.delayed(const Duration(milliseconds: 3000), () async {
      if (!mounted) return;

      bool isLoggedIn = false;
      String? pin;
      bool enablePin = false;

      try {
        isLoggedIn = await LocalStorageService.isLoggedIn();
        pin = await LocalStorageService.getPin();
        enablePin = await LocalStorageService.isPinEnabled();
      } catch (e) {
        if (kDebugMode) {
          print("Error reading local storage: $e");
        }
        isLoggedIn = false;
        pin = null;
        enablePin = false;
      }

      Widget nextScreen;

      if (!isLoggedIn) {
        // Not signed in yet -> sign in options
        nextScreen = const SignInOptionsScreen();
      } else if (!enablePin) {
        // PIN disabled in settings -> go straight to home
        nextScreen = const HomePage();
      } else if (pin == null || pin.isEmpty) {
        // No pin set yet -> force set pin screen
        nextScreen = const SetPinScreen();
      } else {
        // Pin exists and pin is enabled -> show pin entry
        nextScreen = const PinScreen();
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}