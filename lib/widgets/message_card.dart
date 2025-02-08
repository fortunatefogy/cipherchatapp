import 'package:cached_network_image/cached_network_image.dart';
import 'package:cipher/api/apis.dart';
import 'package:cipher/helper/my_date_util.dart';

import 'package:cipher/models/message.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
        ? _blackMessage()
        : _whiteMessage();
  }

  // senders message
  Widget _whiteMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
              minWidth: MediaQuery.of(context).size.width * 0.25,
            ),
            margin: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
            padding: EdgeInsets.all(widget.message.type == Type.text ? 10 : 3),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 197, 193, 193),
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
                      padding: const EdgeInsets.only(left: 10),
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
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
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
      ],
    );
  }

  // our message
  Widget _blackMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
              minWidth: MediaQuery.of(context).size.width * 0.25,
            ),
            margin: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
            padding: EdgeInsets.all(widget.message.type == Type.text ? 10 : 3),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 0, 0),
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
                      padding: const EdgeInsets.only(right: 15),
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
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
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
                      Text(
                        MyDateUtil.getFormattedTime(
                            context: context, time: widget.message.sent),
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 13,
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
      ],
    );
  }
}
