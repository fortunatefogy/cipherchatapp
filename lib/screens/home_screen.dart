// ignore_for_file: unused_import
import 'package:cipher/api/apis.dart';
import 'package:cipher/screens/auth/login_screen.dart';
import 'package:cipher/widgets/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Image(
            image: AssetImage('assets/icon/icon.png'),
            // width: 10,
            // height: 10,
          ),
        ),
        title: const Text('Cipher'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF251d28),
        onPressed: () async {
          await APIs.auth.signOut();
          await GoogleSignIn().signOut();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
          itemCount: 15,
          padding: EdgeInsets.only(top: 10),
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return const ChatUserCard();
          }),
    );
  }
}
