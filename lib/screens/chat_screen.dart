import 'package:cipher/api/apis.dart';
import 'package:cipher/models/chat_user.dart';
import 'package:cipher/models/message.dart';
import 'package:cipher/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
    super.dispose();
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

                return _list.isNotEmpty
                    ? ListView.builder(
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
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_rounded,
                        color: Colors.black),
                    onPressed: () {},
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
