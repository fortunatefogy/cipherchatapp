// ignore_for_file: unused_import
import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cipher/api/apis.dart';
import 'package:cipher/helper/dialogs.dart';
import 'package:cipher/main.dart';
import 'package:cipher/models/chat_user.dart';
import 'package:cipher/screens/auth/login_screen.dart';
import 'package:cipher/widgets/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Size mq;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mq = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              Dialogs.showProgressBar(context);
              await APIs.auth.signOut().then(
                (value) async {
                  await GoogleSignIn().signOut().then((value) {
                    Navigator.pop(context);

                    Navigator.pop(context);
                  });
                },
              );
              ;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
        child: Column(
          children: [
            SizedBox(
              width: mq.width,
              height: mq.height * .05,
            ),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: CachedNetworkImage(
                    width: mq.height * .2,
                    height: mq.height * .2,
                    fit: BoxFit.fill,
                    imageUrl: widget.user.image,
                    placeholder: (context, url) => const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(CupertinoIcons.person),
                    ),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: MaterialButton(
                      onPressed: () {},
                      shape: const CircleBorder(),
                      color: Colors.white,
                      child: Icon(Icons.edit)),
                )
              ],
            ),
            SizedBox(
              height: mq.height * .03,
            ),
            Text(widget.user.email,
                style: const TextStyle(color: Colors.black, fontSize: 20)),
            SizedBox(
              height: mq.height * .03,
            ),
            TextFormField(
              initialValue: widget.user.name,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                hintText: 'Eg: Your Name',
                label: const Text('Name'),
              ),
            ),
            SizedBox(
              height: mq.height * .02,
            ),
            TextFormField(
              initialValue: widget.user.about,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.info_outline),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                hintText: 'Enter your about',
                label: const Text('About'),
              ),
            ),
            SizedBox(
              height: mq.height * .02,
            ),
            ElevatedButton(
              onPressed: () {
                // Add your update logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Background color
                elevation: 3, // Elevation
              ),
              child: const Text(
                'Update',
                style: TextStyle(
                  color: Colors.white, // Font color
                  fontSize: 20, // Font size
                ),
              ),
            ),
            SizedBox(
              height: mq.height * .02,
            ),
          ],
        ),
      ),
    );
  }
}
