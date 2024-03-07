import 'package:chat_app/account_with_contact.dart';
import 'package:chat_app/api/api.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/users_detail.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/screens/selected_contacts.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterflow_paginate_firestore/paginate_firestore.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  List<UsersDetail> listOfMyChatUsers = [];
  List<ChatUser> lists = [];
  List<ChatUser> _searchList = [];
  bool _isSearching = false;
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      print('Message: $message');
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }

        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              leading: Icon(CupertinoIcons.home),
              title: _isSearching
                  ? TextField(
                      style: TextStyle(fontSize: 17),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Name',
                      ),
                      autofocus: true,
                      onChanged: (val) {
                        _searchList.clear();
                        for (var i in lists) {
                          // _searchList.clear();
                          if (val != "") {
                            if ((i.name ?? "")
                                .toLowerCase()
                                .contains(val.toLowerCase())) {
                              _searchList.add(i);
                            }
                          }

                          setState(() {
                            _searchList;
                          });
                        }
                      },
                    )
                  : Text("Chat App"),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        _searchList.clear();
                      });
                    },
                    icon: Icon(_isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search)),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                    user: APIs.me,
                                  )));
                    },
                    icon: Icon(Icons.more_vert)),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelectedContacts()));
              },
              child: Icon(Icons.add_comment_rounded),
            ),
            body: StreamBuilder(
              stream: APIs.getMyChatUserIds(),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                listOfMyChatUsers =
                    data?.map((e) => UsersDetail.fromJson(e.data())).toList() ??
                        [];
                // if (listOfMyUsers.isNotEmpty && snapshot != []) {
                //   return StreamBuilder(
                //     // listOfMyUsers=snapshot.data?.docs.map((e)=>e.id).toList()??[];
                //     stream: APIs.getAllUsers(listOfMyUsers),
                //     builder: (context, snapshot) {
                //       switch (snapshot.connectionState) {
                //         case ConnectionState.waiting:
                //         case ConnectionState.none:
                //           return const Center(
                //               child: CircularProgressIndicator());
                //         case ConnectionState.active:
                //         case ConnectionState.done:
                //           final data = snapshot.data?.docs;
                //           list = data
                //                   ?.map((e) => ChatUser.fromJson(e.data()))
                //                   .toList() ??
                //               [];
                //       }
                //       if (list.isNotEmpty) {
                //         return ListView.builder(
                //             itemCount:
                //                 _isSearching ? _searchList.length : list.length,
                //             padding: EdgeInsets.only(top: mq.height * .01),
                //             physics: BouncingScrollPhysics(),
                //             itemBuilder: (context, index) {
                //               return ChatUserCard(
                //                   user: _isSearching
                //                       ? _searchList[index]
                //                       : list[index]);
                //             });
                //       } else {
                //         return Center(
                //             child: Text(
                //           "No Connection Found!",
                //           style: TextStyle(fontSize: 20),
                //         ));
                //       }
                //     },
                //   );
                // }
                // return Center(
                //   child: Text(
                //     'No Any user added',
                //     style: TextStyle(fontSize: 20),
                //   ),
                // );
                if (listOfMyChatUsers.isNotEmpty && listOfMyChatUsers != []) {
                  return _isSearching
                      ? ListView.builder(
                          itemCount: _searchList.length,
                          padding: EdgeInsets.only(top: mq.height * .01),
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ChatUserCard(
                              user: _searchList[index],
                            );
                          })
                      : ListView.builder(
                          itemCount: listOfMyChatUsers.length,
                          itemBuilder: (context, i) {
                            if (listOfMyChatUsers[i].toId != null) {
                              return PaginateFirestore(
                                itemBuilder: (context, list, index) {
                                  lists.clear();
                                  lists.addAll(list
                                      .map((e) => ChatUser.fromJson(
                                          e.data() as Map<String, dynamic>))
                                      .toList());

                                  // print("your lists length is: $lists");

                                  return ChatUserCard(
                                      user: ChatUser.fromJson((list[index]
                                          .data() as Map<String, dynamic>)));
                                },
                                query: FirebaseFirestore.instance
                                    .collection('users')
                                    .where('id',
                                        isEqualTo: listOfMyChatUsers[i].toId),
                                shrinkWrap: true,
                                // itemsPerPage: 23,
                                physics: BouncingScrollPhysics(),
                                isLive: true,
                                reverse: true,
                                onEmpty: Text(
                                  "No Any user added",
                                  style: TextStyle(fontSize: 20),
                                ),
                                itemBuilderType: PaginateBuilderType.listView,
                              );
                            } else {
                              return Container();
                            }
                          });
                } else {
                  return Center(
                    child: Text("No Any Chat"),
                  );
                }
              },
            )),
      ),
    );
  }
}
