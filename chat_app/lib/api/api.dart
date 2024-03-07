import 'dart:io';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/users_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static late ChatUser me;

  //to return current user
  static User get user => auth.currentUser!;

  static Future<void> getSelfInfo() async {
    await fireStore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

//for checking if user exists or not
  static Future<bool> userExists() async {
    return (await fireStore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<bool> addChatUser(String contact) async {
    final data = await fireStore
        .collection('users')
        .where('contact', isEqualTo: contact)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      fireStore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      return false;
    }
  }

//for creating a new user
  static Future<void> createUser() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? Name = sp.getString('name');
    String? Contact = sp.getString('contact');

    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: Name,
        contact: Contact,
        about: "Hey I'm using we chat",
        image: '',
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');

    return await fireStore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserIds() {
    return fireStore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyChatUserIds() {
    return fireStore.collection('chats').snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    print("\nUSERIds: $userIds");

    return fireStore
        .collection('users')
        .where('id', whereIn: userIds)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    await fireStore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((po) {});

    me.image = await ref.getDownloadURL();

    await fireStore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  static String getConservationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

//Getting All messages of specific conversation from fire store
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return fireStore
        .collection('chats/${getConservationID(user.id!)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return fireStore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool Online) async {
    fireStore.collection('users').doc(user.uid).update({
      'isOnline': Online,
      'lastActive': DateTime.now().millisecondsSinceEpoch.toString()
    });
  }

  static Future<void> sendMessage(
      ChatUser chatUser, String msg, MessageType type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final MessagesModel message = MessagesModel(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);
    final ref = fireStore
        .collection('chats/${getConservationID(chatUser.id!)}/messages/');
    ref.doc(time).set(message.toJson());
  }

  static Future<void> sendLastMessageDetail(
      ChatUser chatUser, String msg, MessageTypes type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final UsersDetail messages = UsersDetail(
        lastMessage: msg,
        lastMessageTime: time,
        fromId: user.uid,
        toId: chatUser.id,
        userName: chatUser.name,
        isTyping: '',
        type: type);
    final ref =
        fireStore.collection('chats').doc(getConservationID(chatUser.id!));
    ref.set(messages.toJson());
  }

  static Future<void> updateMessageReadStatus(MessagesModel message) async {
    fireStore
        .collection('chats/${getConservationID(message.fromId!)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser user) {
    return fireStore
        .collection('chats/${getConservationID(user.id!)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> lastMessagesOfUser(
      ChatUser user) {
    return fireStore
        .collection('chats')
        .where(getConservationID(user.id!))
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getConservationID(chatUser.id!)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((po) {});

    final imageUrl = await ref.getDownloadURL();

    await sendMessage(chatUser, imageUrl, MessageType.image);
    await sendLastMessageDetail(chatUser, imageUrl, MessageTypes.image);
  }
}
