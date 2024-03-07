// To parse this JSON data, do
//
//     final usersDetail = usersDetailFromJson(jsonString);

import 'dart:convert';

//import 'package:chat_app/models/message.dart';

UsersDetail usersDetailFromJson(String str) =>
    UsersDetail.fromJson(json.decode(str));

String usersDetailToJson(UsersDetail data) => json.encode(data.toJson());

class UsersDetail {
  final String? lastMessage;
  final String? lastMessageTime;
  final String? fromId;
  final String? toId;
  final String? userName;
  final String? isTyping;
  final MessageTypes? type;

  UsersDetail({
    this.lastMessage,
    this.lastMessageTime,
    this.fromId,
    this.toId,
    this.userName,
    this.isTyping,
    this.type,
  });

  factory UsersDetail.fromJson(Map<String, dynamic> json) => UsersDetail(
        lastMessage: json["lastMessage"],
        lastMessageTime: json["lastMessageTime"],
        fromId: json["fromId"],
        toId: json["toId"],
        userName: json["userName"],
        isTyping: json["isTyping"],
        type: json["type"].toString() == MessageTypes.image.name
            ? MessageTypes.image
            : MessageTypes.text,
      );

  Map<String, dynamic> toJson() => {
        "lastMessage": lastMessage,
        "lastMessageTime": lastMessageTime,
        "fromId": fromId,
        "toId": toId,
        "userName": userName,
        "isTyping": isTyping,
        "type": type!.name,
      };
}

enum MessageTypes { text, image }
