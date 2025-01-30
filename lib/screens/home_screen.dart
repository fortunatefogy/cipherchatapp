// ignore_for_file: unused_import
import 'dart:convert';
import 'dart:math';

import 'package:cipher/api/apis.dart';
import 'package:cipher/models/chat_user.dart';
import 'package:cipher/screens/auth/login_screen.dart';
import 'package:cipher/screens/profile_screen.dart';
import 'package:cipher/widgets/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: () async {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image(
                image: AssetImage('assets/icon/icon.png'),
                // width: 10,
                // height: 10,
              ),
            ),
            title: Text('Cipher'),
            actions: [
              IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: () {
                  // Add your onPressed code here!
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Profile') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                                user: APIs.me,
                              )),
                    );
                  } else if (value == 'Settings') {
                    // Navigate to settings screen
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {'Profile', 'Settings'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(
                        choice,
                        style: TextStyle(fontSize: 18), // Increased font size
                      ),
                    );
                  }).toList();
                },
                offset: Offset(0, AppBar().preferredSize.height),
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
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                  decoration: InputDecoration(
                    hintText: 'Search User',
                    hintStyle:
                        TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                    filled: true,
                    fillColor: const Color.fromARGB(176, 82, 82, 82),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search,
                        color: const Color.fromARGB(255, 0, 0, 0)),
                  ),
                  onChanged: (val) {
                    _searchList.clear();
                    for (var i in _list) {
                      if (i.email.toLowerCase().contains(val.toLowerCase())) {
                        _searchList.add(i);
                      }
                    }
                    setState(() {
                      _isSearching = val.isNotEmpty;
                    });
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder(
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
                        _list = data
                                ?.map((e) => ChatUser.fromJson(e.data()))
                                .toList() ??
                            [];
                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            itemCount: _isSearching
                                ? _searchList.length
                                : _list.length,
                            padding: EdgeInsets.only(top: 10),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ChatUserCard(
                                user: _isSearching
                                    ? _searchList[index]
                                    : _list[index],
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: Text('No users found'),
                          );
                        }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
