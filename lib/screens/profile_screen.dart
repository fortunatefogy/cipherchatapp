import 'dart:convert';
import 'dart:io';
import 'package:cipher/api/apis.dart';
import 'package:cipher/helper/dialogs.dart';
import 'package:cipher/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:cipher/api/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Widget showProgressBar() {
    return Center(
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
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
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  late Size mq;
  String? _image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mq = MediaQuery.of(context).size;
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _uploadImageToCloudinary(File imageFile) async {
    final cloudinaryUrl =
        'https://api.cloudinary.com/v1_1/dshlsnsyt/image/upload';
    final uploadPreset = 'cipher';

    final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      final imageUrl = jsonResponse['secure_url'];

      print('Cloudinary Image URL: $imageUrl'); // Debug output

      await APIs.updateUserImage(imageUrl).then((value) {
        setState(() {
          widget.user.image = imageUrl; // Update the image field
          _image = null; // Reset the local image path
        }); // Print updated image URL
        Dialogs.showSnackbar(context, 'Profile Image Updated');
      });
    } else {
      Dialogs.showSnackbar(context, 'Image Upload Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    print(
        'Current Profile Picture URL: ${widget.user.image}'); // Print current profile picture URL

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .05,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: Image.file(File(_image!),
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.cover))
                          : GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: CachedNetworkImage(
                                            imageUrl: widget.user.image,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Center(
                                                    child: showProgressBar()),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: CircleAvatar(
                                            backgroundColor:
                                                themeProvider.isDarkMode
                                                    ? Colors.black
                                                    : Colors.white,
                                            child: IconButton(
                                              icon: Icon(Icons.close,
                                                  color:
                                                      themeProvider.isDarkMode
                                                          ? Colors.white
                                                          : Colors.black),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: CachedNetworkImage(
                                  key: ValueKey(widget.user.image),
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.cover,
                                  imageUrl: widget.user.image,
                                  placeholder: (context, url) =>
                                      const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(CupertinoIcons.person),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(CupertinoIcons.person),
                                  ),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                            onPressed: () {
                              _showBottomSheet(context);
                            },
                            shape: const CircleBorder(),
                            color: themeProvider.isDarkMode
                                ? Colors.black
                                : Colors.white,
                            child: Icon(
                              Icons.edit,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            )),
                      )
                    ],
                  ),
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  Text(widget.user.email,
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                        fontSize: 20,
                      )),
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty
                        ? null
                        : 'Name is required',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      hintText: 'Eg: Your Name',
                      label: const Text('Name'),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty
                        ? null
                        : 'About is required',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.info_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      hintText: 'Enter your about',
                      label: const Text('About'),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(context, 'Profile Updated');
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black, // Background color
                      elevation: 3, // Elevation
                    ),
                    child: Text(
                      'Update',
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.black
                            : Colors.white, // Font color
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
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.2,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Pick Profile Picture",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      backgroundColor: themeProvider.isDarkMode
                          ? Colors.black
                          : Colors.white,
                      padding: EdgeInsets.all(10), // Background color
                      elevation: 5,
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        Navigator.pop(context);
                        await _uploadImageToCloudinary(File(image.path));
                      }
                    },
                    child: SvgPicture.asset(
                      'assets/icon/camera.svg', // SVG file
                      width: 60, // Adjust size
                      height: 60,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      backgroundColor: themeProvider.isDarkMode
                          ? Colors.black
                          : Colors.white,
                      padding: EdgeInsets.all(10), // Background color
                      elevation: 5,
                    ),
                    onPressed: () async {
                      print('Image URL: ${widget.user.image}');
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        Navigator.pop(context);
                        await _uploadImageToCloudinary(File(image.path));
                      }
                    },
                    child: SvgPicture.asset(
                      'assets/icon/gallery.svg', // SVG file
                      width: 60,
                      height: 60,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
