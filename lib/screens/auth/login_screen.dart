// import 'dart:math';

import 'dart:io';
// import 'dart:math';
// import 'dart:developer';

import 'package:cipher/api/apis.dart';
import 'package:cipher/helper/dialogs.dart';
import 'package:cipher/main.dart';
import 'package:cipher/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late PageController _controller;
  double _scale = 0.0;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xffF9F4FB),
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    // Start the scale animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _scale = 1.0;
      });
    });
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    _controller.dispose();
    super.dispose();
  }

  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);
    signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        print('\nUser: ${user.user}');
        print('\nUserAdditionalInfo: ${user.additionalUserInfo}');
        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    try {
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      print("\nsignInWithGoogle: $e");
      Dialogs.showSnackbar(context, 'something went wrong(Check internet!)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Color(0xFFF8EB69B), // Set the background color to blue
          ),
          Positioned(
            top: mq.height * 0.20,
            left: mq.width * .25,
            width: mq.width * .5,
            child: AnimatedScale(
              scale: _scale,
              duration: Duration(seconds: 2),
              child: Image.asset('assets/icon/icon.png'),
            ),
          ),
          Positioned(
            top: mq.height * .45,
            left: mq.width * .085,
            width: mq.width * .9,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
              child: Text(
                "Privacy isn't a feature, it's our foundation #",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Mulish',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            bottom: mq.height * 0.25,
            left: mq.width * .15,
            width: mq.width * .7,
            height: mq.height * 0.05,
            child: ElevatedButton.icon(
              onPressed: () {
                _handleGoogleBtnClick();
              },
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/icon/google.png'),
              ),
              label: Text(
                'Signin with Google',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                  elevation: 10,
                  backgroundColor: Colors.black), // Background color
            ),
          ),
        ],
      ),
    );
  }
}
