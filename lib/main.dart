// import 'package:cipher/onboarding_screen.dart';
import 'package:cipher/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            color: Colors.black,
          ),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // Increased font weight
            fontSize: 28,
          ),
          backgroundColor: Color(0xFFF9F4FB),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
