// ignore_for_file: unused_import
import 'dart:convert';
import 'dart:math';

import 'package:cipher/api/apis.dart';
import 'package:cipher/models/chat_user.dart';
import 'package:cipher/screens/auth/login_screen.dart';
import 'package:cipher/screens/profile_screen.dart';
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
  List<ChatUser> list = [];

  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                          user: APIs.me,
                        )),
              );
            },
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
      body: StreamBuilder(
        stream: APIs.getAllUsers(), // Add your stream here
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            // if data is loading
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());
            // if some or all data is loaded
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) {
                return ListView.builder(
                    itemCount: list.length,
                    padding: EdgeInsets.only(top: 10),
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ChatUserCard(
                        user: list[index],
                      );
                      // return Text('Name:${list[index]}');
                    });
              } else {
                return const Center(
                  child: Text('No users found'),
                );
              }
          }
        },
      ),
    );
  }
}
