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

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  Future<void> _captureAndSaveImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      try {
        Uint8List imageBytes = await File(image.path).readAsBytes();

        await SaverGallery.saveImage(
          imageBytes,
          quality: 80,
          fileName: "captured_image.jpg",
          androidRelativePath: "Pictures/CipherApp/Images",
          skipIfExists: false,
        );

        Dialogs.showSnackbar(context, "Image saved successfully");
      } catch (e) {
        Dialogs.showSnackbar(context, "Error saving image: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () async {
          if (_isSearching) {
            setState(() => _isSearching = false);
            return false;
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.asset('assets/icon/icon.png'),
            ),
            title: const Text('Cipher'),
            actions: [
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () => _captureAndSaveImage(context),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Profile') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(user: APIs.me),
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'Profile',
                    child: Text('Profile', style: TextStyle(fontSize: 18)),
                  )
                ],
                offset: Offset(0, AppBar().preferredSize.height),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF251d28),
            onPressed: () async {
              await APIs.auth.signOut();
              await GoogleSignIn().signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: Column(
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
                    fillColor: Colors.grey.shade300,
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
                      if (user.email
                          .toLowerCase()
                          .contains(val.toLowerCase())) {
                        _searchList.add(user);
                      }
                    }
                    setState(() => _isSearching = val.isNotEmpty);
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.connectionState == ConnectionState.none) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data?.docs;
                    _list = data
                            ?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                        [];

                    return _list.isNotEmpty
                        ? ListView.builder(
                            itemCount: _isSearching
                                ? _searchList.length
                                : _list.length,
                            padding: const EdgeInsets.only(top: 10),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ChatUserCard(
                                user: _isSearching
                                    ? _searchList[index]
                                    : _list[index],
                              );
                            },
                          )
                        : const Center(
                            child: Text('No users found'),
                          );
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
