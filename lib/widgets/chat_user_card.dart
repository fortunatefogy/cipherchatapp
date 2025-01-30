import 'package:cached_network_image/cached_network_image.dart';
import 'package:cipher/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  late Size mq;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mq = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      color: const Color.fromARGB(255, 191, 199, 204),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {},
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .3),
            child: CachedNetworkImage(
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
              // placeholder: (context, url) => const CircleAvatar(
              //   child: Icon(CupertinoIcons.person),
              // ),
              // errorWidget: (context, url, error) => const CircleAvatar(
              //   child: Icon(CupertinoIcons.person),
              // ),
            ),
          ),
          title: Text(
            widget.user.name,
            maxLines: 1,
          ),
          subtitle: Text(
            widget.user.about,
            maxLines: 1,
          ),
          //   trailing: Text("12:00 PM"),
          // ),
          trailing: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
