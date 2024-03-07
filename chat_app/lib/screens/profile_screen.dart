import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/api.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ProfileScreen> {
  @override
  final TextEditingController nameController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final GlobalKey<FormState> logKey = GlobalKey<FormState>();
  String? _image;

  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    void _showBottomSheet() {
      showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          builder: (_) {
            return ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                  top: mq.height * .03, bottom: mq.height * .05),
              children: [
                Text(
                  "pick profile picture",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: mq.height * .02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            fixedSize: Size(mq.width * .3, mq.height * .15)),
                        onPressed: () async {
                          try {
                            ImagePicker picker = ImagePicker();
                            XFile? image = await picker.pickImage(
                                source: ImageSource.gallery, imageQuality: 80);
                            if (image != null) {
                              print(
                                  'Image Path: ${image.path} -- MimeType: ${image.mimeType}');
                              setState(() {
                                _image = image.path;
                              });

                              APIs.updateProfilePicture(File(_image!));
                            }
                            Navigator.pop(context);
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Image.asset('images/GallryPhoto.png')),
                    // SizedBox(
                    //   width: mq.width * .15,
                    // ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            fixedSize: Size(mq.width * .3, mq.height * .15)),
                        onPressed: () async {
                          try {
                            ImagePicker picker = ImagePicker();
                            XFile? image = await picker.pickImage(
                                source: ImageSource.camera, imageQuality: 80);
                            if (image != null) {
                              print('Image Path: ${image.path}');
                              setState(() {
                                _image = image.path;
                              });
                              APIs.updateProfilePicture(File(_image!));
                            }
                            Navigator.pop(context);
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Image.asset('images/CameraPhoto.png')),
                  ],
                ),
                SizedBox(
                  height: mq.height * .02,
                ),
              ],
            );
          });
    }

    String? nameValidate(value) {
      if (value == null || value.trim().isEmpty) {
        return "Please enter name";
      }
      return null;
    }

    String? aboutValidate(value) {
      if (value == null || value.trim().isEmpty) {
        return "Please enter your about";
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Scfreen"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        onPressed: () {
          APIs.updateActiveStatus(false);
          APIs.auth.signOut();
          GoogleSignIn().signOut();

          Navigator.pop(context);
          APIs.auth = FirebaseAuth.instance;
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SplashScreen()));
        },
        icon: Icon(Icons.logout),
        label: Text("LogOut"),
      ),
      body: Form(
        key: logKey,
        child: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              width: mq.width,
              height: mq.height * .03,
            ),
            // Set your desired background color here
            Stack(
              children: [
                _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .1),
                        child: Image.file(
                          File(_image!),
                          width: mq.height * .2,
                          height: mq.height * .2,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .1),
                        child: CachedNetworkImage(
                          width: mq.height * .2,
                          height: mq.height * .2,
                          fit: BoxFit.cover,
                          imageUrl: widget.user.image ?? "",
                          // placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              CircleAvatar(child: Icon(CupertinoIcons.person)),
                        ),
                      ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: MaterialButton(
                    elevation: 1,
                    onPressed: () {
                      _showBottomSheet();
                    },
                    shape: CircleBorder(),
                    color: Colors.white,
                    child: Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),
                  ),
                )
              ],
            ),

            SizedBox(
              height: mq.height * .03,
            ),

            Text(
              widget.user.contact.toString(),
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(
              height: mq.height * .03,
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .03),
              child: TextFormField(
                onSaved: (val) => APIs.me.name = val ?? '',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: widget.user.name,
                decoration: InputDecoration(
                    prefix: Icon(
                      Icons.person,
                      color: Colors.blue,
                    ),
                    hintText: 'Name',
                    label: Text('Name'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
                validator: nameValidate,
              ),
            ),

            SizedBox(
              height: mq.height * .03,
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .03),
              child: TextFormField(
                onSaved: (val) => APIs.me.about = val ?? '',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: widget.user.about,
                decoration: InputDecoration(
                    prefix: Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                    ),
                    hintText: 'About',
                    label: Text('About'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
                validator: aboutValidate,
              ),
            ),

            SizedBox(
              height: mq.height * .03,
            ),

            InkWell(
              onTap: () {
                if (logKey.currentState!.validate()) {
                  logKey.currentState!.save();
                  APIs.updateUserInfo().then((value) {
                    Dialogs.showSnackbar(
                        context, 'Profile Update Successfully', 'Success');
                  });
                }
              },
              child: Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue),
                child: Row(children: [
                  SizedBox(
                    width: mq.width * .03,
                  ),
                  Icon(Icons.update),
                  SizedBox(
                    width: mq.width * .03,
                  ),
                  Text(
                    "Update",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )
                ]),
              ),
            ),

            //  ElevatedButton.icon(

            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.green,
            //     shape: StadiumBorder(),
            //     maximumSize: Size(mq.width*.7, mq.height*.66)),
            //   onPressed:(){}, icon: Icon(Icons.edit),label: Text("Update"),)
          ]),
        ),
      ),
    );
  }
}
