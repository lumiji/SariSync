import 'package:flutter/material.dart';
import 'local_storage_service.dart';
import 'package:sarisync/views/set_pin_screen.dart';
import 'package:sarisync/views/pin_screen.dart';

class AuthFlowService {
  static Future<void> handlePostLogin(BuildContext context) async {
    // Mark user as logged in
    await LocalStorageService.saveLoggedIn();

    // Check if PIN exists
    String? pin = await LocalStorageService.getPin();

    if (pin == null || pin.isEmpty) {
      // NO PIN → go to Set PIN screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SetPinScreen()),
      );
    } else {
      // HAS PIN → go to Enter PIN screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PinScreen()),
      );
    }
  }
}
