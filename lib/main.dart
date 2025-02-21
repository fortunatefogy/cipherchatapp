import 'package:cipher/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cipher/api/apis.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

late Size mq;

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized(); // Ensures proper initialization
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform); // Wait for Firebase to initialize
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  static const String THEME_KEY = 'theme_key';

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? darkTheme : lightTheme;
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
        color: Color.fromARGB(255, 0, 0, 0),
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      backgroundColor: Color(0xFF2C2C2C),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2C2C2C),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (APIs.auth.currentUser != null) {
      if (state == AppLifecycleState.resumed) {
        // When app is resumed/active
        APIs.updateActiveStatus(true);
      } else {
        // When app is paused/inactive/detached
        APIs.updateActiveStatus(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cipher',
          theme: themeProvider.themeData,
          home:  SplashScreen(),
        );
      },
    );
  }
}