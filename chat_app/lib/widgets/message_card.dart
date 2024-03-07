import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/api.dart';
import 'package:chat_app/helper/my_data_util.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageCard extends StatefulWidget {
  final MessagesModel message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return APIs.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  Widget _blueMessage() {
    if (widget.message.read!.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            padding: EdgeInsets.all(widget.message.type == MessageType.image
                ? mq.width * .02
                : mq.width * .04),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.lightBlue),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
              color: const Color.fromARGB(255, 194, 222, 246),
            ),
            child: widget.message.type == MessageType.text
                ? Text(
                    widget.message.msg.toString(),
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg ?? "",
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      placeholder: (context, url) => CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Row(
          children: [
            Text(
              MyDateUtil.getFormatedtime(
                  context: context, time: widget.message.sent.toString()),
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            SizedBox(
              width: mq.width * .04,
            ),
          ],
        ),
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * .04,
            ),
            widget.message.read!.isNotEmpty
                ? Icon(
                    Icons.done_all_rounded,
                    color: Colors.blue,
                    size: 20,
                  )
                : Icon(
                    Icons.done_sharp,
                    size: 20,
                  ),
            SizedBox(
              width: 2,
            ),
            Text(
              MyDateUtil.getFormatedtime(
                  context: context, time: widget.message.sent.toString()),
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            padding: EdgeInsets.all(widget.message.type == MessageType.image
                ? mq.width * .02
                : mq.width * .04),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.lightGreen),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30)),
              color: const Color.fromARGB(255, 170, 231, 172),
            ),
            child: widget.message.type == MessageType.text
                ? Text(
                    widget.message.msg.toString(),
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg ?? "",
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      placeholder: (context, url) => CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // seenMessageCondition() {}
}
