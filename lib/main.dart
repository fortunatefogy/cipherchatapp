import 'package:cipher/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cipher/api/apis.dart';
import 'firebase_options.dart';

late Size mq;

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized(); // Ensures proper initialization
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions
          .currentPlatform); // Wait for Firebase to initialize
  runApp(const MyApp());
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cipher',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 2,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          backgroundColor: Color(0xFFF235347),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
