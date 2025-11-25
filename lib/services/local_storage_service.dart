import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_pin", pin);
  }

  static Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_pin");
  }

  // new: return whether PIN is enabled (default true)
  static Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('enablePin') ?? true;
  }

  // optional: convenience setter if you don't already have one
  static Future<void> setPinEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enablePin', enabled);
  }

  static Future<void> saveLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_logged_in", true);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("is_logged_in") ?? false;
  }
}
