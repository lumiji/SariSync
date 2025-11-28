//dependencies
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//pages
import 'home.dart';
import 'change_pin_screen.dart';
import 'user_guide_page.dart';
import 'contact_support_page.dart';
import 'about_sarisync_page.dart';
import 'sign-in_options.dart';
//widgets
import 'package:sarisync/widgets/message_prompts.dart';
//services
import 'package:sarisync/services/local_storage_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool enablePin = true;
  bool autoCleanup = false;
  String? schedule;
  bool weekly = false;
  bool monthly = false;
  bool lowStocksAlert = false;
  bool scheduledDataCleanup = false;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      enablePin = prefs.getBool('enablePin') ?? true;
      lowStocksAlert = prefs.getBool('lowStocksAlert') ?? false;
      scheduledDataCleanup = prefs.getBool('scheduledDataCleanup') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadSettings(); // Call load settings here
    loadAutoCleanupSettings(); // added

    LocalStorageService.getAutoCleanupEnabled().then((value) {
      setState(() => autoCleanup = value);
    });
    LocalStorageService.getCleanupSchedule().then((value) {
      setState(() => schedule = value);
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enablePin', enablePin);
    await prefs.setBool('lowStocksAlert', lowStocksAlert);
    await prefs.setBool('scheduledDataCleanup', scheduledDataCleanup);
  }

  Future<void> loadAutoCleanupSettings() async {
    bool enabled = await LocalStorageService.getAutoCleanupEnabled();
    String? schedule = await LocalStorageService.getCleanupSchedule();

    setState(() {
      autoCleanup = enabled;
      if (!enabled) {
        // If cleanup disabled → do not activate checkboxes
        weekly = false;
        monthly = false;
      } else if (schedule == "weekly") {
        weekly = true;
        monthly = false;
      } else if (schedule == "monthly") {
        weekly = false;
        monthly = true;
      }
    });
  }

  Future<void> signOutUser() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Google Sign Out
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      } catch (e) {}

      // Facebook Sign Out
      try {
        await FacebookAuth.instance.logOut();
      } catch (e) {}

       await LocalStorageService.clearUserData();

    } catch (e) {
      print("Sign out error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF7FBFF), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        titleSpacing: -2,
        title: Text(
          "Settings",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20, 
            color: Colors.white,
            fontWeight: FontWeight.w600
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24 ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          // SECURITY
          sectionHeader("Security"),

          // Enable PIN
          customSwitchTile(
            title: "Enable PIN",
            value: enablePin,
            onChanged: (v) {
              setState(() {
                enablePin = v;
              });
              saveSettings();
            },
          ),

          // Change PIN (depends ONLY on Enable PIN)
          customListTile(
            title: "Change PIN",
            enabled: enablePin,
            onTap: enablePin
                ? () {
                    DialogHelper.confirmDelete(
                      context,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePinScreen(),
                          ),
                        );
                      },
                      title: "Do you want to change your PIN?",
                      yesText: "Yes",
                      noText: "No",
                    );
                  }
                : null,
          ),

          const SizedBox(height: 16),

          // DATA MANAGEMENT
          sectionHeader("Data Management"),

          // Enable Auto Cleanup
          customSwitchTile(
            title: "Enable Auto-Cleanup",
            value: autoCleanup,
            onChanged: (v) async {
              setState(() {
                autoCleanup = v;
                if (!v) {
                  weekly = false;
                  monthly = false;
                }
              });
              await LocalStorageService.saveAutoCleanupEnabled(autoCleanup);

              if (!v) {
                await LocalStorageService.saveCleanupSchedule(
                  "",
                ); // reset schedule
              }
              saveSettings(); // saves other settings only
            },
          ),

          // Set Cleanup Schedule (gray if disabled)
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 4),
            child: Text(
              "Set Cleanup Schedule",
              style: TextStyle( fontFamily: 'Inter',
                fontSize: 15,
                color: autoCleanup ? Colors.black : Colors.grey,
              ),
            ),
          ),

          // WEEKLY
          customCheckboxTile(
            title: "Weekly (7 Days)",
            value: weekly,
            enabled: autoCleanup,
            activeColor: Colors.black,
            onChanged: autoCleanup
                ? (v) async {
                    setState(() {
                      weekly = v!;
                      if (v) monthly = false; //only one can be selected
                    });
                    // await LocalStorageService.saveAutoCleanupEnabled(
                    //   autoCleanup,
                    // );
                    await LocalStorageService.saveCleanupSchedule("weekly");
                  }
                : null,
          ),

          // MONTHLY
          customCheckboxTile(
            title: "Monthly (30 Days)",
            value: monthly,
            enabled: autoCleanup,
            activeColor: Colors.black,
            onChanged: autoCleanup
                ? (v) async {
                    setState(() {
                      monthly = v!;
                      if (v) weekly = false; //only one can be selected
                    });
                    // await LocalStorageService.saveAutoCleanupEnabled(
                    //   autoCleanup,
                    // );
                    await LocalStorageService.saveCleanupSchedule("monthly");
                  }
                : null,
          ),

          // CLEAR DATA
          customListTile(
            title: "Clear Data",
            enabled: true,
            onTap: () {
              DialogHelper.confirmDelete(
                context,
                () async {
                  // Show loading first while clearing of data
                  DialogHelper.showLoading(
                    context,
                    message: "Clearing all data. Please wait...",
                  );

                  // Clearing data from Firestore and Local
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  final userRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid);

                  // Delet Firestore subcollections
                  for (final collection in [
                    'History',
                    'inventory',
                    'ledger',
                    'receipts',
                    'dailySales',
                  ]) {
                    final snapshot = await userRef.collection(collection).get();
                    for (var doc in snapshot.docs) {
                      await doc.reference.delete();
                    }
                  }

                  //Clear local storage through shared preferences
                  //SharedPreferences prefs = await SharedPreferences.getInstance();
                  //await prefs.clear();

                  // After delete, show success popup
                  DialogHelper.success(
                    context,
                    "All data has been cleared successfully!",
                    onOk: () {
                      // Navigate back to Home Page
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                        (route) => false,
                      );
                    },
                  );
                },
                title:
                    "Clear All Data?\nAll saved records will be permanently removed.\nThis action cannot be undone.",
                yesText: "Yes",
                noText: "No",
              );
            },
          ),

          const SizedBox(height: 16),

          // ABOUT / HELP
          sectionHeader("About/Help"),

          customListTile(
            title: "User Guide / How To Use",
            enabled: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserGuidePage()),
              );
            },
          ),

          customListTile(
            title: "Contact Support",
            enabled: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ContactSupportPage()),
              );
            },
          ),

          customListTile(
            title: "About SariSync",
            enabled: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AboutSariSyncPage()),
              );
            },
          ),

          const SizedBox(height: 20),

          // LOGOUT
          ListTile(
            title: Text(
              "Logout",
              style: TextStyle( fontFamily: 'Inter',
                fontSize: 16,
                color: const Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              final result = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Logout"),
                  content: Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text("Logout"),
                    ),
                  ],
                ),
              );

              if (result == true) {
                await signOutUser();

                // Navigate to Login Page & remove history
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => SignInOptionsScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 10),
      child: Text(
        text,
        style: TextStyle( fontFamily: 'Inter',fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }

  // Custom SwitchListTile design
  Widget customSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(title, style: TextStyle( fontFamily: 'Inter',fontSize: 15)),
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: const Color(0xFFCFE9FF), // pastel blue
          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          thumbColor: WidgetStatePropertyAll(
            value ? const Color(0xFF1976D2) : Colors.grey,
          ),
        ),
        //Divider(thickness: 0.5, height: 0),
      ],
    );
  }

  // Custom CheckboxListTile
  Widget customCheckboxTile({
    required String title,
    required bool value,
    required bool enabled,
    required Function(bool?)? onChanged,
    Color? activeColor,
  }) {
    return Column(
      children: [
        CheckboxListTile(
          title: Text(
            title,
            style: TextStyle( fontFamily: 'Inter',
              fontSize: 15,
              color: enabled ? Colors.black : Colors.grey,
            ),
          ),
          value: value,
          onChanged: enabled ? onChanged : null,
          controlAffinity: ListTileControlAffinity.leading,

          // Checkbox color behavior
          activeColor: enabled
              ? (activeColor ??
                    Colors.lightBlue) // color when enabled & checked
              : Colors.grey, // gray if autoCleanup is disabled
          checkColor: enabled ? Colors.white : Colors.black26,
        ),
        // Divider(thickness: 0.5, height: 0),
      ],
    );
  }

  Widget customListTile({
    required String title,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          color: enabled ? Colors.black : Colors.grey,
        ),
      ),
      enabled: enabled,
      onTap: enabled ? onTap : null,
      trailing: null,
      //trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
