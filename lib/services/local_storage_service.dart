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

  // New methods for account information
  static Future<void> saveAccountInfo(String identifier, String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("account_identifier", identifier);
    await prefs.setString("account_type", type);
  }

  static Future<String?> getAccountIdentifier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("account_identifier");
  }

  static Future<String?> getAccountType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("account_type");
  }

  // Optional: Clear all user data on logout
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("user_pin");
    await prefs.remove("is_logged_in");
    await prefs.remove("account_identifier");
    await prefs.remove("account_type");
  }
}