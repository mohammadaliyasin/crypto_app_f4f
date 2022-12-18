
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static bool isDarkModeEnabled = false;

 static Future<void> getThemeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    isDarkModeEnabled = prefs.getBool('isDarkMode') ?? false;
  }
}
