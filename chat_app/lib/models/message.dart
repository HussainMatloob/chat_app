// To parse this JSON data, do
//
//     final messagesModel = messagesModelFromJson(jsonString);

import 'dart:convert';

MessagesModel messagesModelFromJson(String str) =>
    MessagesModel.fromJson(json.decode(str));

String messagesModelToJson(MessagesModel data) => json.encode(data.toJson());

class MessagesModel {
  final String? fromId;
  final String? msg;
  final String? read;
  final String? sent;
  final String? toId;
  final MessageType? type;

  MessagesModel({
    this.fromId,
    this.msg,
    this.read,
    this.sent,
    this.toId,
    this.type,
  });

  factory MessagesModel.fromJson(Map<String, dynamic> json) => MessagesModel(
        fromId: json["fromId"].toString(),
        msg: json["msg"].toString(),
        read: json["read"].toString(),
        sent: json["sent"].toString(),
        toId: json["toId"].toString(),
        type: json["type"].toString() == MessageType.image.name
            ? MessageType.image
            : MessageType.text,
      );

  Map<String, dynamic> toJson() => {
        "fromId": fromId,
        "msg": msg,
        "read": read,
        "sent": sent,
        "toId": toId,
        "type": type!.name,
      };
}

enum MessageType { text, image }
