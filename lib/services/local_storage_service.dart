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

  static Future<void> saveLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_logged_in", true);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("is_logged_in") ?? false;
  }
}
