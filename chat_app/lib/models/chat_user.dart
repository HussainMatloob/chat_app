import 'dart:convert';

ChatUser chatUserFromJson(String str) => ChatUser.fromJson(json.decode(str));

String chatUserToJson(ChatUser data) => json.encode(data.toJson());

class ChatUser {
  String? image;
  String? about;
  String? name;
  String? createdAt;
  bool? isOnline;
  String? id;
  String? lastActive;
  String? contact;
  String? pushToken;

  ChatUser({
    this.image,
    this.about,
    this.name,
    this.createdAt,
    this.isOnline,
    this.id,
    this.lastActive,
    this.contact,
    this.pushToken,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        image: json["image"] ?? '',
        about: json["about"] ?? '',
        name: json["name"] ?? '',
        createdAt: json["createdAt"] ?? '',
        isOnline: json["isOnline"],
        id: json["id"] ?? '',
        lastActive: json["lastActive"] ?? '',
        contact: json["contact"] ?? '',
        pushToken: json["pushToken"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "about": about,
        "name": name,
        "createdAt": createdAt,
        "isOnline": isOnline,
        "id": id,
        "lastActive": lastActive,
        "contact": contact,
        "pushToken": pushToken,
      };
}
