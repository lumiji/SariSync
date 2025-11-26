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

  // Check connectivity before attempting Firebase initialization
  final connectivityResult = await Connectivity().checkConnectivity();
  final bool hasConnection = connectivityResult.first != ConnectivityResult.none;

  // Initialize Firebase with error handling for offline scenarios
  bool firebaseInitialized = false;
  if (hasConnection) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      firebaseInitialized = true;
      
      // Enable offline persistence only if Firebase initialized successfully
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED
      );
      
      if (kDebugMode) {
        print("Firebase initialized successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Firebase initialization failed: $e");
      }
      // App will continue to work with local data only
    }
  } else {
    if (kDebugMode) {
      print("No internet connection - skipping Firebase initialization");
    }
  }

  if (kDebugMode) {
    print("Running in Debug mode");
  } else if (kReleaseMode) {
    print("Running in Release mode");
  } else if (kProfileMode) {
    print("Running in Profile mode");
  }

  runApp(MyApp(firebaseInitialized: firebaseInitialized));

  await Future.delayed(const Duration(seconds: 1));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;
  
  const MyApp({super.key, required this.firebaseInitialized});

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
      home: ConnectivityWrapper(
        child: InitialNavigator(firebaseInitialized: firebaseInitialized),
      ),
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
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        final bool nowOnline = result.first != ConnectivityResult.none;
        
        if (nowOnline != _isOnline) {
          setState(() {
            _isOnline = nowOnline;
            _showBanner = true;
          });

          // Auto-hide banner after 3 seconds if back online
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
      },
    );
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
  final bool firebaseInitialized;
  
  const InitialNavigator({super.key, required this.firebaseInitialized});

  @override
  State<InitialNavigator> createState() => _InitialNavigatorState();
}

class _InitialNavigatorState extends State<InitialNavigator> {
  bool _isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    _isOfflineMode = !widget.firebaseInitialized;
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
        // If offline, show message that sign-in requires internet
        if (_isOfflineMode) {
          nextScreen = const OfflineSignInScreen();
        } else {
          nextScreen = const SignInOptionsScreen();
        }
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (_isOfflineMode) ...[
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Running in offline mode',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Offline screen shown when user tries to sign in without internet
class OfflineSignInScreen extends StatefulWidget {
  const OfflineSignInScreen({super.key});

  @override
  State<OfflineSignInScreen> createState() => _OfflineSignInScreenState();
}

class _OfflineSignInScreenState extends State<OfflineSignInScreen> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    // Automatically navigate to sign-in when connection is restored
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        if (result.first != ConnectivityResult.none && !_isRetrying) {
          _retryConnection();
        }
      },
    );
  }

  Future<void> _retryConnection() async {
    if (_isRetrying) return;
    
    setState(() {
      _isRetrying = true;
    });

    // Check if we have internet
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool hasConnection = connectivityResult.first != ConnectivityResult.none;

    if (hasConnection) {
      // Try to initialize Firebase
      try {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        
        // Enable offline persistence
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED
        );

        if (!mounted) return;
        
        // Navigate to sign-in options
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInOptionsScreen()),
        );
        return;
      } catch (e) {
        if (kDebugMode) {
          print("Retry failed: $e");
        }
      }
    }

    // Still offline or failed
    if (mounted) {
      setState(() {
        _isRetrying = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Still no connection. Please try again.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              const Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'SariSync requires an internet connection to start. Please check your connection and try again.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isRetrying ? null : _retryConnection,
                icon: _isRetrying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isRetrying ? 'Connecting...' : 'Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}