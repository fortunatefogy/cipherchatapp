// ignore_for_file: unused_import, deprecated_member_use
import 'dart:typed_data';
import 'dart:io';
import 'package:cipher/api/apis.dart';
import 'package:cipher/main.dart';
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
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  bool _isUserDataLoaded = false;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _menuKey = GlobalKey();
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await APIs.getSelfInfo();
    if (mounted) {
      setState(() {
        _isUserDataLoaded = true;
      });
    }
  }

  void _showCustomMenu() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
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
          value: 'theme',
          child: Row(
            children: [
              Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.black87,
              ),
              const SizedBox(width: 10),
              Text(themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.black87),
              SizedBox(width: 10),
              Text('Logout'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'theme') {
        themeProvider.toggleTheme();
      } else if (value == 'logout') {
        _logout();
      }
    });
  }

  void _logout() async {
    Dialogs.showProgressBar(context);
    await APIs.auth.signOut().then(
      (value) async {
        await GoogleSignIn().signOut().then((value) {
          if (mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        });
      },
    );
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUserDataLoaded) {
      return Scaffold(
        body: Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/icon/icon.png',
                    width: 40,
                    height: 40,
                  ),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 0, 0, 0)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
            IconButton(
              key: _menuKey,
              icon: const Icon(Icons.more_vert),
              onPressed: _showCustomMenu,
            ),
          ],
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
                backgroundColor: const Color(0xFFF141517),
                onPressed: _addChatUserDialog,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            _buildChatPage(),
            ProfileScreen(user: APIs.me),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 225, 228, 237),
          selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
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
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildChatPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Search User',
              hintStyle: const TextStyle(color: Colors.black),
              filled: true,
              fillColor: const Color.fromARGB(255, 225, 228, 237),
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
                  _list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];

                  _list.sort((a, b) =>
                      (b.isOnline ? 1 : 0).compareTo(a.isOnline ? 1 : 0));

                  if (_list.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }

                  return ListView.builder(
                    itemCount: _isSearching ? _searchList.length : _list.length,
                    padding: const EdgeInsets.only(top: 10),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ChatUserCard(
                        user: _isSearching ? _searchList[index] : _list[index],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _addChatUserDialog() {
    String email = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xffFFF4F18),
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
            prefixIcon:
                const Icon(Icons.email, color: Color.fromARGB(255, 0, 0, 0)),
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
              borderSide: const BorderSide(color: Color(0xffF235347)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
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
            child: const Text("Add", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }
}
