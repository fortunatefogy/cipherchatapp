import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  static const String THEME_KEY = 'theme_key';

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(THEME_KEY) ?? false;
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_KEY, _isDarkMode);
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? darkTheme : lightTheme;
  }

  TextStyle get chatCardTextStyle {
    return _isDarkMode ? darkChatCardTextStyle : lightChatCardTextStyle;
  }

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFF141517),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      backgroundColor: Color(0xFFFFF4F18),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 225, 228, 237),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFF141517),
    scaffoldBackgroundColor: const Color(0xFF1F1F1F),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      backgroundColor: Color(0xFF2C2C2C),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 244, 0, 0),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    ),
  );

  // Text styles
  static final TextStyle lightChatCardTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
  );

  static final TextStyle darkChatCardTextStyle = TextStyle(
    backgroundColor: Colors.transparent,
    color: const Color.fromARGB(255, 0, 0, 0),
    fontSize: 16,
  );
}
