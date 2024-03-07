import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/api.dart';
import 'package:chat_app/controller/emoji_controller.dart';
import 'package:chat_app/controller/imageUploading_controller.dart';
import 'package:chat_app/helper/my_data_util.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/users_detail.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// 'package:flutter/foundation.dart' as foundation;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutterflow_paginate_firestore/paginate_firestore.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  TextEditingController textController = TextEditingController();
  EmojiController emojiController = Get.put(EmojiController());
  imageUploadingController imageController =
      Get.put(imageUploadingController());

  //for storing value showing or hiding emoji
  List<MessagesModel> list = [];
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        //    onWillPop: () {
        //     GetBuilder<EmojiController>(builder: (controller){
        //   // return controller.showEmoji?controller.emoji(controller.showEmoji): Future.value(true);
        //      if (controller.showEmoji) {
        //      controller.emoji(controller.showEmoji);
        //     return Future.value(false);
        //   } else {
        //     return Future.value(true);
        //   }
        //     },);

        // },
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 220, 231, 241),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appbar(),
          ),
          body: Column(children: [
            // Expanded(
            //   child: StreamBuilder(
            //     stream: APIs.getAllMessages(widget.user),
            //     builder: (context, snapshot) {
            //       switch (snapshot.connectionState) {
            //         case ConnectionState.waiting:
            //         case ConnectionState.none:
            //           return const SizedBox();
            //         case ConnectionState.active:
            //         case ConnectionState.done:
            //           final data = snapshot.data?.docs;
            //           list = data
            //                   ?.map((e) => MessagesModel.fromJson(e.data()))
            //                   .toList() ??
            //               [];
            //       }
            //       if (list.isNotEmpty) {
            //         return ListView.builder(
            //             reverse: true,
            //             itemCount: list.length,
            //             padding: EdgeInsets.only(top: mq.height * .01),
            //             physics: BouncingScrollPhysics(),
            //             itemBuilder: (context, index) {
            //               return MessageCard(
            //                 message: list[index],
            //               );
            //             });
            //       } else {
            //         return Center(
            //             child: Text(
            //           "Say Hii 👋!",
            //           style: TextStyle(fontSize: 20),
            //         ));
            //       }
            //     },
            //   ),
            // ),

            Expanded(
              child: PaginateFirestore(
                itemBuilder: (context, list, index) {
                  return MessageCard(
                      message: (MessagesModel.fromJson(
                          (list[index].data() as Map<String, dynamic>))));
                },
                query: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(APIs.getConservationID(widget.user.id!))
                    .collection('messages')
                    .orderBy('sent', descending: true),
                shrinkWrap: true,
                // itemsPerPage: 23,
                isLive: true,
                reverse: true,
                onEmpty: Text(
                  "Say Hii 👋!",
                  style: TextStyle(fontSize: 20),
                ),
                itemBuilderType: PaginateBuilderType.listView,
              ),
            ),

            GetBuilder<imageUploadingController>(
              builder: (controller) {
                return controller.isUploadingStatus
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            )))
                    : Container();
              },
            ),
            _chatInput(),
            GetBuilder<EmojiController>(builder: (Controller) {
              if (Controller.showEmoji) {
                return SizedBox(
                  height: mq.height * .35,
                  child: EmojiPicker(
                    textEditingController: textController,
                    config: Config(
                      emojiViewConfig: EmojiViewConfig(
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  ),
                );
              }
              return Container();
            }),
          ]),
        ),
      ),
    );
  }

  Widget _appbar() {
    return InkWell(
      onTap: () {},
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black54,
                  )),
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .3),
                child: CachedNetworkImage(
                  width: mq.height * 0.05,
                  height: mq.height * 0.05,
                  imageUrl: list.isNotEmpty
                      ? list[0].image ?? ""
                      : widget.user.image ?? "",
                  // placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.isNotEmpty
                        ? list[0].name.toString()
                        : widget.user.name.toString(),
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline!
                            ? 'online'
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive.toString())
                        : MyDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive.toString()),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue,
                    ),
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  GetBuilder<EmojiController>(builder: (controller) {
                    return IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          controller.emoji(controller.showEmoji);
                        },
                        icon: Icon(
                          Icons.emoji_emotions,
                          color: Colors.blueAccent,
                        ));
                  }),
                  GetBuilder<EmojiController>(builder: (controller) {
                    return Expanded(
                        child: TextField(
                      controller: textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (controller.showEmoji) {
                          controller.emoji(controller.showEmoji);
                        }
                      },
                      decoration: InputDecoration(
                          hintText: 'Text',
                          hintStyle: TextStyle(color: Colors.blueAccent),
                          border: InputBorder.none),
                    ));
                  }),
                  GetBuilder<imageUploadingController>(
                    builder: (controller) {
                      return IconButton(
                          onPressed: () async {
                            ImagePicker picker = ImagePicker();
                            List<XFile> images =
                                await picker.pickMultiImage(imageQuality: 80);
                            if (images.isNotEmpty) {
                              for (var i in images) {
                                controller
                                    .imageUpload(controller.isUploadingStatus);
                                print('Image Path: ${i.path}');
                                await APIs.sendChatImage(
                                    widget.user, File(i.path));
                                controller
                                    .imageUpload(controller.isUploadingStatus);
                              }
                            }
                          },
                          icon: Icon(
                            Icons.image,
                            color: Colors.blueAccent,
                          ));
                    },
                  ),
                  GetBuilder<imageUploadingController>(
                    builder: (controller) {
                      return IconButton(
                          onPressed: () async {
                            ImagePicker picker = ImagePicker();
                            XFile? image = await picker.pickImage(
                                source: ImageSource.camera, imageQuality: 80);
                            if (image != null) {
                              controller
                                  .imageUpload(controller.isUploadingStatus);
                              print('Image Path: ${image.path}');
                              await APIs.sendChatImage(
                                  widget.user, File(image.path));
                              controller
                                  .imageUpload(controller.isUploadingStatus);
                            }
                          },
                          icon: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.blueAccent,
                          ));
                    },
                  ),
                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                APIs.sendMessage(
                    widget.user, textController.text, MessageType.text);
                APIs.sendLastMessageDetail(
                    widget.user, textController.text, MessageTypes.text);
                textController.text = '';
              }
            },
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            color: Colors.green,
            child: Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
