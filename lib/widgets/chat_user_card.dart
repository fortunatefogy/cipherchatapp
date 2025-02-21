import 'package:cached_network_image/cached_network_image.dart';
import 'package:cipher/api/apis.dart';
import 'package:cipher/api/theme_provider.dart';
import 'package:cipher/helper/my_date_util.dart';
import 'package:cipher/models/chat_user.dart';
import 'package:cipher/models/message.dart';
import 'package:cipher/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  late Size mq;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mq = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        color: themeProvider.isDarkMode
            ? const Color(0xFF2C2C2C)
            : const Color.fromARGB(255, 225, 228, 237),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)),
            );
          },
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Text(widget.user.name),
                  content: const Text("Select an action"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        APIs.deleteChat(widget.user);
                        // Perform delete action
                        Navigator.pop(context);
                      },
                      child: const Text("Delete Chat"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                );
              },
            );
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;

              if (data == null || data.isEmpty) {
                _message = null;
              } else if (data.first.exists) {
                _message = Message.fromJson(data.first.data());
              }

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .3),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(150),
                            ),
                            backgroundColor: Colors.transparent,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipOval(
                                  child: Image.network(
                                    widget.user.image,
                                    fit: BoxFit.cover,
                                    width: mq.height * .3,
                                    height: mq.height * .3,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      maxWidth: 30,
                                      maxHeight: 30,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.black, size: 15),
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
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: mq.height * .055,
                      height: mq.height * .055,
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
                ),
                title: Text(
                  widget.user.name,
                  maxLines: 1,
                  style: themeProvider.chatCardTextStyle.copyWith(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.user.isOnline)
                      const Text(
                        'Online',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 15,
                        ),
                      ),
                    Text(
                      _message != null
                          ? _message!.type == Type.image
                              ? 'Image'
                              : _message!.msg
                          : '',
                      maxLines: 1,
                      style: themeProvider.chatCardTextStyle.copyWith(
                        fontSize: 14,
                        color: themeProvider.isDarkMode
                            ? Colors.grey
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                            _message!.fromId != APIs.user.uid
                        ? Container(
                            width: 15,
                            height: 15,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          )
                        : Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: themeProvider.chatCardTextStyle.copyWith(
                              fontSize: 12,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
              );
            },
          ),
        ),
      ),
    );
  }
}
