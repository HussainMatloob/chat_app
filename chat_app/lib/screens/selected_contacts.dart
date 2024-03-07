import 'package:chat_app/api/api.dart';
import 'package:chat_app/controller/selectedContacts_controller.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterflow_paginate_firestore/paginate_firestore.dart';
import 'package:get/get.dart';

class SelectedContacts extends StatefulWidget {
  const SelectedContacts({super.key});

  @override
  State<SelectedContacts> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<SelectedContacts> {
  @override
  // SelectedContactController selectedContactController =
  //     Get.put(SelectedContactController());

  List<ChatUser> _listUsers = [];
  //List<ChatUser> _searchListUsers = [];
  //bool _Searching = false;
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
    //mq = MediaQuery.of(context).size;
    // return GestureDetector(
    //   onTap: () => FocusScope.of(context).unfocus(),
    //   child: WillPopScope(
    //     onWillPop: () {
    //       if (_Searching) {
    //         setState(() {
    //           _Searching = !_Searching;
    //         });
    //         return Future.value(false);
    //       } else {
    //         return Future.value(true);
    //       }
    //     },
    return GetBuilder<SelectedContactController>(
      init: SelectedContactController(),
      builder: (selectedContactController) {
        return Scaffold(
          appBar: AppBar(
            title: selectedContactController.searching
                ? TextField(
                    style: TextStyle(fontSize: 17),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name',
                    ),
                    autofocus: true,
                    onChanged: (val) {
                      selectedContactController.searchListClear();
                      for (var i in _listUsers) {
                        // _searchList.clear();
                        if (val != "") {
                          if ((i.name ?? "")
                              .toLowerCase()
                              .contains(val.toLowerCase())) {
                            selectedContactController.addSearchUserInList(i);
                          }
                        }
                      }
                    },
                  )
                : Text(
                    "Selected Contacts",
                    style: TextStyle(fontSize: 18),
                  ),
            actions: [
              IconButton(
                  onPressed: () {
                    selectedContactController
                        .searchByName(selectedContactController.searching);
                    selectedContactController.searchListClear();
                  },
                  icon: Icon(selectedContactController.searching
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
          body: ListView(
            children: [
              ListTile(
                onTap: () {
                  _addChatUserDialog();
                },
                leading: Icon(
                  Icons.person_add,
                  size: 30,
                ),
                title: Text("New Contact"),
              ),
              ListTile(
                title: Text("Contacts on We Chat"),
              ),
              StreamBuilder(
                stream: APIs.getMyUserIds(),
                builder: (context, snapshot) {
                  List<String> listOfMyUsers =
                      snapshot.data?.docs.map((e) => e.id).toList() ?? [];

                  if (listOfMyUsers.isNotEmpty && listOfMyUsers != []) {
                    print("The length of user is" + listOfMyUsers.toString());
                    return selectedContactController.searching
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: selectedContactController
                                .lengthOfSearchListUsers,
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, i) {
                              // print("Search List length is" +
                              //     selectedContactController
                              //         .lengthOfSearchListUsers
                              //         .toString());

                              return ChatUserCard(
                                user: selectedContactController
                                    .searchListUsers[i],
                              );
                            })
                        : PaginateFirestore(
                            itemBuilder: (context, list, index) {
                              _listUsers.clear();
                              _listUsers.addAll(list.map((DocumentSnapshot e) {
                                return ChatUser.fromJson(
                                    e.data() as Map<String, dynamic>);
                              }).toList());

                              print("your lists length is: $_listUsers");

                              return ChatUserCard(
                                  user: ChatUser.fromJson((list[index].data()
                                      as Map<String, dynamic>)));
                            },
                            query: FirebaseFirestore.instance
                                .collection('users')
                                .where('id', whereIn: listOfMyUsers),
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
                    return Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
    // ),
    //);
  }

  void _addChatUserDialog() {
    String contact = '';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding:
                  EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text(" Add User"),
                ],
              ),
              content: TextFormField(
                initialValue: '+92',
                maxLines: null,
                onChanged: (value) => contact = value,
                decoration: InputDecoration(
                    hintText: 'Contact',
                    // prefix: Icon(Icons.contact_emergency),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    if (contact.isNotEmpty) {
                      await APIs.addChatUser(contact).then((value) {
                        if (!value) {
                          Get.snackbar(
                            'Error',
                            'User does not Exist',
                            colorText: Colors.black,
                            backgroundColor: Colors.green,
                            snackPosition: SnackPosition.TOP,
                            onTap: (SnackBar) {},
                          );
                        } else {
                          Get.snackbar(
                            'Success',
                            'User added successfully',
                            colorText: Colors.black,
                            backgroundColor: Colors.green,
                            snackPosition: SnackPosition.TOP,
                            onTap: (SnackBar) {},
                          );
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
            ));
  }
}
