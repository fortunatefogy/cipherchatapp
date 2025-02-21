// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cipher/api/apis.dart';
import 'package:cipher/helper/dialogs.dart';
import 'package:cipher/helper/my_date_util.dart';
import 'package:cipher/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:saver_gallery/saver_gallery.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

Future<void> _saveImageFromChat(String imageUrl, BuildContext context) async {
  try {
    final response = await HttpClient().getUrl(Uri.parse(imageUrl));
    final bytes =
        await consolidateHttpClientResponseBytes(await response.close());

    await SaverGallery.saveImage(
      bytes,
      quality: 80,
      fileName: "chat_image.jpg",
      androidRelativePath: "Pictures/CipherApp/Images",
      skipIfExists: false,
    );

    Dialogs.showSnackbar(context, "Image saved successfully");
  } catch (e) {
    Dialogs.showSnackbar(context, "Error saving image: $e");
  }
}

class _MessageCardState extends State<MessageCard> {
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

  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: isMe ? _blackMessage() : _whiteMessage());
  }

  // senders message
  Widget _whiteMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
                minWidth: MediaQuery.of(context).size.width * 0.30,
              ),
              margin: EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 5,
              ),
              padding:
                  EdgeInsets.all(widget.message.type == Type.text ? 10 : 9),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 222, 225, 229),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 1),
                        child: widget.message.type == Type.text
                            ? Text(
                                widget.message.msg,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: widget.message.msg,
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.broken_image),
                                  placeholder: (context, url) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: showProgressBar(),
                                    ),
                                  ),
                                  // width: 200,
                                  // height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      SizedBox(height: 20), // Add some space for the time
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        MyDateUtil.getFormattedTime(
                            context: context, time: widget.message.sent),
                        style: TextStyle(
                            color: const Color.fromARGB(137, 0, 0, 0),
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // our message
  Widget _blackMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
                minWidth: MediaQuery.of(context).size.width * 0.30,
              ),
              margin: EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 5,
              ),
              padding:
                  EdgeInsets.all(widget.message.type == Type.text ? 10 : 1),
              decoration: BoxDecoration(
                color: const Color(0xFFF141517),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 1),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: widget.message.type == Type.text
                              ? Text(
                                  widget.message.msg,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.message.msg,
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.broken_image),
                                    placeholder: (context, url) => Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: showProgressBar(),
                                      ),
                                    ),
                                    // width: 200,
                                    // height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 20), // Add some space for the time
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            MyDateUtil.getFormattedTime(
                                context: context, time: widget.message.sent),
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        if (widget.message.read.isNotEmpty)
                          Icon(
                            Icons.done_all,
                            color: Colors.blue,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 100),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              widget.message.type == Type.text
                  ? _OptionItem(
                      icon: Icon(
                        Icons.copy,
                        color: Theme.of(context).iconTheme.color,
                        size: 26,
                      ),
                      name: "Copy Message",
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);
                          Dialogs.showSnackbar(context, "Message copied ");
                        });
                      },
                    )
                  : _OptionItem(
                      icon: Icon(
                        Icons.download,
                        color: Theme.of(context).iconTheme.color,
                        size: 26,
                      ),
                      name: "Download Image",
                      onTap: () {
                        _saveImageFromChat(widget.message.msg, context);
                        Navigator.pop(context);
                        Dialogs.showSnackbar(context, "Saved to gallery");
                      },
                    ),
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).iconTheme.color,
                      size: 26,
                    ),
                    name: "Edit Message",
                    onTap: () {
                      print("Debug: Edit button tapped"); // Debug print
                      Navigator.pop(context);
                      // Use a small delay to ensure bottom sheet is closed
                      Future.delayed(Duration(milliseconds: 100), () {
                        _showMessageUpdateDialog(context);
                      });
                    }),
              _OptionItem(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).iconTheme.color,
                    size: 26,
                  ),
                  name:
                      "Sent at :${MyDateUtil.getLastMessageTime(context: context, time: widget.message.sent)}",
                  onTap: () {}),
              _OptionItem(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Theme.of(context).iconTheme.color,
                    size: 26,
                  ),
                  name: widget.message.read.isEmpty
                      ? "Not seen yet"
                      : "Read at :${MyDateUtil.getFormattedTime(context: context, time: widget.message.read)}",
                  onTap: () {}),
              if (isMe)
                _OptionItem(
                    icon: Icon(
                      Icons.delete,
                      color: const Color.fromARGB(255, 255, 0, 0),
                      size: 26,
                    ),
                    name: "Delete Message",
                    onTap: () async {
                      await APIs.deleteMessage(widget.message).then((value) {
                        Dialogs.showSnackbar(context, "Message deleted");
                        Navigator.pop(context);
                      });
                    }),
            ],
          );
        });
  }

  void _showMessageUpdateDialog(BuildContext context) {
    String updatedMsg = widget.message.msg;
    final FocusNode _focusNode = FocusNode();

    showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Theme.of(context).iconTheme.color,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text("Update Message")
                ],
              ),
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                autofocus: true,
                focusNode: _focusNode,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: Text("Cancel")),
                TextButton(
                    onPressed: () async {
                      try {
                        // First close the dialog
                        Navigator.of(dialogContext).pop();

                        // Then update the message and show the snackbar
                        await APIs.updateMessage(widget.message, updatedMsg);

                        // Use mounted check before showing snackbar
                        if (context.mounted) {
                          Dialogs.showSnackbar(context, "Message updated");
                        }
                      } catch (e) {
                        // If there's an error, show it using the parent context
                        if (context.mounted) {
                          Dialogs.showSnackbar(
                              context, "Failed to update message: $e");
                        }
                      }
                    },
                    child: Text("Update"))
              ],
            ));

    // Ensure keyboard shows up
    Future.delayed(Duration(milliseconds: 100), () {
      if (_focusNode.hasListeners) {
        // Check if focusNode is still valid
        _focusNode.requestFocus();
      }
    });
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, top: 15),
        child: Row(
          children: [icon, Flexible(child: Text('    $name'))],
        ),
      ),
    );
  }
}
