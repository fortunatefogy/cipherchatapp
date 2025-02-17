// ignore_for_file: unused_import, deprecated_member_use
import 'dart:typed_data';
import 'dart:io';
import 'package:cipher/api/apis.dart';
import 'package:cipher/models/chat_user.dart';
import 'package:cipher/screens/auth/login_screen.dart';
import 'package:cipher/screens/profile_screen.dart';
import 'package:cipher/widgets/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:cipher/helper/dialogs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _menuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  void _showCustomMenu() {
    final RenderBox renderBox =
        _menuKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height,
        position.dx + size.width,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: const [
              Icon(Icons.person, color: Colors.black87),
              SizedBox(width: 10),
              Text('Profile'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'profile') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(user: APIs.me),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Image.asset('assets/icon/icon.png'),
          ),
          title: const Text('Cipher'),
          actions: [
            // Menu button that shows dropdown below appbar
            IconButton(
              key: _menuKey,
              icon: const Icon(Icons.more_vert),
              onPressed: _showCustomMenu,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFF235347),
          onPressed: _addChatUserDialog,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Column(
          children: [
            // Search Bar with updated style
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search User',
                  hintStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: const Color(0xFFF8EB69B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.black),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchList.clear();
                              _isSearching = false;
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  _searchList.clear();
                  for (var user in _list) {
                    if (user.email.toLowerCase().contains(val.toLowerCase()) ||
                        user.name.toLowerCase().contains(val.toLowerCase())) {
                      _searchList.add(user);
                    }
                  }
                  setState(() => _isSearching = val.isNotEmpty);
                },
              ),
            ),

            // Chat List
            Expanded(
              child: StreamBuilder(
                stream: APIs.getMyUsersId(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.none) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final userIds =
                      snapshot.data?.docs.map((e) => e.id).toList() ?? [];
                  if (userIds.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }

                  return StreamBuilder(
                    stream: APIs.getAllUsers(userIds),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final data = snapshot.data?.docs;
                      _list = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                          [];

                      // Sort users: Online users first, then offline ones
                      _list.sort((a, b) =>
                          (b.isOnline ? 1 : 0).compareTo(a.isOnline ? 1 : 0));

                      if (_list.isEmpty) {
                        return const Center(child: Text('No users found'));
                      }

                      return ListView.builder(
                        itemCount:
                            _isSearching ? _searchList.length : _list.length,
                        padding: const EdgeInsets.only(top: 10),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ChatUserCard(
                            user: _isSearching
                                ? _searchList[index]
                                : _list[index],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color.fromARGB(255, 237, 247, 238),
          selectedItemColor: Color(0xffF235347),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(user: APIs.me),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xffF8EB69B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        title: const Text(
          "Add User",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: TextFormField(
          onChanged: (value) => email = value,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Enter email',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.email, color: Color(0xffF235347)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xffF235347),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              )),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (email.isNotEmpty) {
                bool success = await APIs.addChatUser(email);
                if (!success) {
                  Dialogs.showSnackbar(context, "User not found");
                }
              }
            },
            child: const Text(
              "Add",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
  }
}
