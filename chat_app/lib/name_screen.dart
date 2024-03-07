import 'package:chat_app/api/api.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final GlobalKey<FormState> logKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();

  @override
  String? nameValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your Name";
    }
    return null;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Form(
        key: logKey,
        child: Column(children: [
          SizedBox(
            height: 70,
          ),
          Align(
            child: SizedBox(
              width: 340,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: nameController,
                decoration: InputDecoration(
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffEE7EB)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffEE7EB)),
                  ),
                  hintText: 'Name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: nameValidate,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () async {
              if (logKey.currentState!.validate()) {
                SharedPreferences sp = await SharedPreferences.getInstance();
                sp.setString('name', nameController.text);
                // sp.setBool('Boolean', true);

                // String? Name = sp.getString('name');
                // print("Myname is:" + Name.toString());

                if ((await APIs.userExists())) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                } else {
                  await APIs.createUser().then((value) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  });
                }
              }
            },
            child: Container(
              height: 60,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(child: Text("Ok")),
            ),
          ),
        ]),
      ),
    );
  }
}
