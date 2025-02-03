import 'package:cipher/api/apis.dart';
import 'package:cipher/models/chat_user.dart';
import 'package:cipher/models/message.dart';
import 'package:cipher/widgets/message_card.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  // for handling text input
  final _textController = TextEditingController();

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
                                color: const Color.fromARGB(255, 255, 255, 255),
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                maxWidth: 40,
                                maxHeight: 40,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.close,
                                    color: const Color.fromARGB(255, 0, 0, 0)),
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
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: TextStyle(fontSize: 25),
                ),
                Text(
                  'Last seen: ${widget.user.lastActive}',
                  style: TextStyle(fontSize: 12),
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
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

                return _list.isNotEmpty
                    ? ListView.builder(
                        itemCount: _list.length,
                        padding: const EdgeInsets.only(top: 10),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return MessageCard(
                            message: _list[index],
                          );
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
          _chatInput(_textController, widget.user)
        ],
      ),
    );
  }
}

Widget _chatInput(TextEditingController textController, ChatUser user) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 7),
    child: Row(
      children: [
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.emoji_emotions_rounded,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.image_rounded,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
                SizedBox(width: 5),
              ],
            ),
          ),
        ),
        MaterialButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                APIs.sendMessage(user, textController.text);
                textController.clear();
              }
            },
            minWidth: 0,
            color: Colors.grey.shade300,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            child: Icon(
              Icons.send,
              color: Colors.black,
            )),
      ],
    ),
  );
}
