import 'dart:convert';
import 'dart:io';

import 'package:cipher/api/apis.dart';
import 'package:cipher/helper/dialogs.dart';
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
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmoji) {
        setState(() {
          _showEmoji = false;
        });
      }
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
      child: Scaffold(
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
                  Text(widget.user.name, style: const TextStyle(fontSize: 18)),
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
                                color: isOnline ? Colors.green : Colors.grey,
                              ),
                            ),
                            Text(
                              isOnline
                                  ? 'Online'
                                  : 'Last seen: ${_formatLastSeen(lastActive)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
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
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Offstage(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 12, right: 12),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_rounded,
                        color: Colors.black),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },
                  ),
                  Expanded(
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
                  IconButton(
                    icon: const Icon(Icons.camera_alt_rounded,
                        color: Colors.black),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        setState(() {
                          _isUploading = true;
                        });
                        setState(() {});
                        await _uploadImageToCloudinary(
                            File(image.path), widget.user);
                        setState(() {
                          _isUploading = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 5),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text);
                _textController.clear();
              }
            },
            minWidth: 0,
            color: Colors.grey.shade300,
            padding: const EdgeInsets.all(10),
            shape: const CircleBorder(),
            child: const Icon(Icons.send, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
