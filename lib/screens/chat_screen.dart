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

      Dialogs.showSnackbar(context, 'Image Sent Successfully');
    } else {
      Dialogs.showSnackbar(context, 'Image Upload Failed');
    }
  }

  List<Message> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false;
  FocusNode _focusNode = FocusNode();

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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(widget.user.image),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                maxWidth: 40,
                                maxHeight: 40,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.black),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ),
                        ],
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
                Text('Last seen: ${widget.user.lastActive}',
                    style: const TextStyle(fontSize: 12)),
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
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return _list.isNotEmpty
                    ? ListView.builder(
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
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {});
                        // Navigator.pop(context);
                        await _uploadImageToCloudinary(
                            File(image.path), widget.user);
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
                        setState(() {});
                        // Navigator.pop(context);
                        await _uploadImageToCloudinary(
                            File(image.path), widget.user);
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
                _scrollToBottom();
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
