// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:cipher/api/apis.dart';
import 'package:cipher/helper/dialogs.dart';
import 'package:cipher/helper/my_date_util.dart';
import 'package:cipher/models/chat_user.dart';
import 'package:cipher/models/message.dart';
import 'package:cipher/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? _wallpaperPath;
  final ScrollController _scrollController = ScrollController();

  Future<void> _uploadImageToCloudinary(
      File imageFile, ChatUser chatUser) async {
    final cloudinaryUrl =
        'https://api.cloudinary.com/v1_1/dshlsnsyt/image/upload/';
    final uploadPreset = 'cipher';

    final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'chatimages'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      final imageUrl = jsonResponse['secure_url'];

      print('Cloudinary Image URL: $imageUrl'); // Debug output

      await APIs.sendImageMessage(
          chatUser, imageUrl); // Store encrypted image in Firestore
    } else {
      Dialogs.showSnackbar(context, 'Image Upload Failed');
    }
  }

  List<Message> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false;
  FocusNode _focusNode = FocusNode();

  String _formatLastSeen(String lastActive) {
    if (lastActive.isEmpty) return 'Last seen recently';

    final DateTime lastActiveTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(lastActive));
    final Duration difference = DateTime.now().difference(lastActiveTime);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays == 1) return 'yesterday';
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    return 'long time ago';
  }

  @override
  void initState() {
    _loadWallpaper();
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmoji) {
        setState(() {
          _showEmoji = false;
        });
      }
    });
  }

  Future<void> _loadWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _wallpaperPath = prefs.getString('chat_wallpaper');
    });
  }

  Future<void> _setWallpaper(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_wallpaper', imagePath);
    setState(() {
      _wallpaperPath = imagePath;
    });
  }

  Future<void> _setDefaultWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_wallpaper');
    setState(() {
      _wallpaperPath = null;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_showEmoji) {
      setState(() {
        _showEmoji = false;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        decoration: _wallpaperPath != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(_wallpaperPath!)),
                  fit: BoxFit.cover,
                ),
              )
            : null,
        child: Scaffold(
          backgroundColor: _wallpaperPath != null ? Colors.transparent : null,
          // resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      NetworkImage(widget.user.image),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.user.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.user.email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.user.about,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Joined: ${MyDateUtil.getFormattedDate(widget.user.createdAt)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Close',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.user.image),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.user.name,
                        style: const TextStyle(fontSize: 18)),
                    StreamBuilder(
                      stream: APIs.firestore
                          .collection('users')
                          .doc(widget.user.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final userData = snapshot.data!.data();
                          final isOnline = userData?['is_online'] ?? false;
                          final lastActive = userData?['last_active'] ?? '';

                          return Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isOnline
                                      ? const Color.fromARGB(255, 44, 227, 98)
                                      : Colors.grey,
                                ),
                              ),
                              Text(
                                isOnline
                                    ? 'Online'
                                    : 'Last seen: ${_formatLastSeen(lastActive)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ],
                          );
                        }
                        return const Text(
                          'Last seen: loading...',
                          style: TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                offset: const Offset(0, 50),
                onSelected: (value) {
                  if (value == 'clear_chat') {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Clear Chat'),
                          content: const Text(
                              'Do you want to clear the chat for both?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                APIs.clearChatForSender(widget.user);
                                // Add your clear chat for you logic here
                                print('Clear chat for you selected');
                                Navigator.of(context).pop();
                              },
                              child: const Text('Clear Chat'),
                            ),
                            TextButton(
                              onPressed: () {
                                // APIs.clearChatForBoth(widget.user);
                                // Add your clear chat for both logic here
                                // print('Clear chat for both selected');
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (value == 'set_wallpaper') {
                    final ImagePicker picker = ImagePicker();
                    picker
                        .pickImage(source: ImageSource.gallery)
                        .then((image) async {
                      if (image != null) {
                        await _setWallpaper(image.path);
                        // Save the selected image path to shared preferences or any storage
                        // and use it to set the background wallpaper
                        print('Wallpaper selected: ${image.path}');
                      }
                    });
                  } else if (value == 'set_default_wallpaper') {
                    _setDefaultWallpaper();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'clear_chat',
                      child: Text('Clear Chat'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'set_wallpaper',
                      child: Text('Set Wallpaper'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'set_default_wallpaper',
                      child: Text('Set Default Wallpaper'),
                    ),
                  ];
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.connectionState == ConnectionState.none) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data?.docs;
                    _list =
                        data?.map((e) => Message.fromJson(e.data())).toList() ??
                            [];

                    return _list.isNotEmpty
                        ? ListView.builder(
                            reverse: true,
                            controller: _scrollController,
                            itemCount: _list.length,
                            padding: const EdgeInsets.only(top: 10),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return MessageCard(message: _list[index]);
                            },
                          )
                        : const Center(
                            child: Text(
                              'Say Hi 👋!',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          );
                  },
                ),
              ),
              if (_isUploading)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: CircularProgressIndicator(),
                  ),
                ),
              _chatInput(),
              Offstage(
                offstage: !_showEmoji,
                child: SizedBox(
                  height: 360,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      emojiViewConfig: const EmojiViewConfig(
                          backgroundColor: Colors.white, emojiSizeMax: 26),
                      viewOrderConfig: const ViewOrderConfig(
                        top: EmojiPickerItem.searchBar,
                        middle: EmojiPickerItem.emojiView,
                        bottom: EmojiPickerItem.categoryBar,
                      ),
                      skinToneConfig: const SkinToneConfig(),
                      categoryViewConfig: const CategoryViewConfig(
                          backgroundColor: Colors.white,
                          dividerColor: Colors.white,
                          iconColorSelected: Colors.black,
                          indicatorColor: Colors.black),
                      bottomActionBarConfig: const BottomActionBarConfig(
                          backgroundColor: Colors.white,
                          buttonColor: Color.fromARGB(255, 172, 172, 172),
                          buttonIconColor: Colors.black,
                          showBackspaceButton: true),
                      searchViewConfig: const SearchViewConfig(
                          hintText: "Search Emoji",
                          backgroundColor: Colors.white,
                          buttonIconColor: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17, left: 12, right: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: IconButton(
                      icon: const Icon(Icons.emoji_emotions_rounded,
                          color: Colors.black),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 150,
                      ),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          reverse: true,
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onTap: () {
                              if (_showEmoji) {
                                setState(() {
                                  _showEmoji = false;
                                });
                              }
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Message',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image_rounded, color: Colors.black),
                    onPressed: () async {
                      print('Image URL: ${widget.user.image}');
                      final ImagePicker picker = ImagePicker();
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);
                      for (var i in images) {
                        setState(() {
                          _isUploading = true;
                        });
                        await _uploadImageToCloudinary(
                            File(i.path), widget.user);
                        setState(() {
                          _isUploading = false;
                        });
                      }
                    },
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _textController,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 7),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt_rounded,
                                color: Colors.black),
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                  source: ImageSource.camera);
                              if (image != null) {
                                setState(() {
                                  _isUploading = true;
                                });
                                await _uploadImageToCloudinary(
                                    File(image.path), widget.user);
                                setState(() {
                                  _isUploading = false;
                                });
                              }
                            },
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(width: 5),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 5, right: 5),
            child: MaterialButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  if (_list.isEmpty) {
                    APIs.sendFirstMessage(
                        widget.user, _textController.text, Type.text);
                  } else {
                    APIs.sendMessage(
                        widget.user, _textController.text, Type.text);
                    _textController.clear();
                  }
                }
              },
              minWidth: 0,
              color: Colors.grey.shade300,
              padding: const EdgeInsets.all(10),
              shape: const CircleBorder(),
              child: const Icon(Icons.send, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
