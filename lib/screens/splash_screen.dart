import 'package:cipher/api/apis.dart';
import 'package:cipher/onboarding_screen.dart';
import 'package:cipher/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Set system UI mode to edge-to-edge
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Set system navigation bar color to white
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xffF9F4FB),
      statusBarColor: Color(0xFFF9F4FB),
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    Timer(Duration(seconds: 2), () {
      User? user = APIs.auth.currentUser;
      if (user != null) {
        print('\nUser: ${APIs.auth.currentUser}');
        // User is signed in, navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // No user is signed in, navigate to onboarding screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F4FB), // Set background color to blue
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/icon/icon.png',
              width: 160.0,
              height: 160.0,
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Text(
                'Cipher',
                style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 34, 36, 37),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
