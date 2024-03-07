import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/api.dart';
import 'package:chat_app/helper/my_data_util.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/users_detail.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  UsersDetail? _message;

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Container(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.symmetric(horizontal: mq.width * .02, vertical: 4),
        color: Colors.blue.shade100,
        shadowColor: Colors.red,
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(user: widget.user)));
            },
            //  child: PaginateFirestore(
            //                     itemBuilder: (context, list, index) {

            //                       return ChatUserCard(
            //                           user: ChatUser.fromJson((list[index].data()
            //                               as Map<String, dynamic>)));
            //                     },
            //                     query: APIs.lastMessagesOfUser(widget.user),
            //                     shrinkWrap: true,
            //                     // itemsPerPage: 23,
            //                     physics: BouncingScrollPhysics(),
            //                     isLive: true,
            //                     reverse: true,
            //                     onEmpty: Text(
            //                       "No Any user added",
            //                       style: TextStyle(fontSize: 20),
            //                     ),
            //                     itemBuilderType: PaginateBuilderType.listView,
            //                   ),

            child: StreamBuilder(
              stream: APIs.lastMessagesOfUser(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => UsersDetail.fromJson(e.data())).toList() ??
                        [];

                if (list.isNotEmpty) {
                  _message = list[0];
                }

                return ListTile(
                  title: Text(widget.user.name.toString()),
                  // leading:CircleAvatar(child: Icon(CupertinoIcons.person),),
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(mq.height * .3),
                    ),
                    // Set your desired background color here
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .3),
                      child: CachedNetworkImage(
                        width: mq.height * 0.055,
                        height: mq.height * 0.055,
                        imageUrl: widget.user.image ?? "",
                        // placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            CircleAvatar(child: Icon(CupertinoIcons.person)),
                      ),
                    ),
                  ),

                  //  trailing: Text('12:00 PM'),
                  trailing: _message == null
                      ? null
                      : Text(
                          MyDateUtil.getLastMessagesTime(
                              context: context,
                              time: _message!.lastMessageTime.toString()),
                          style: TextStyle(color: Colors.black54),
                        ),
                  subtitle: Text(_message != null
                      ? _message!.type == MessageTypes.image
                          ? "image"
                          : _message!.lastMessage.toString()
                      : widget.user.about.toString()),
                );
              },
            )),
      ),
    );
  }
}
