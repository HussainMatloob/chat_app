import 'package:chat_app/opt_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final GlobalKey<FormState> logKey = GlobalKey<FormState>();
  final TextEditingController contactController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    contactController.text = '+92';
  }

  String? contactValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter Contact number";
    }
    bool contactRegex = RegExp(r'^\+[0-9]{12}$').hasMatch(value);

    if (contactRegex == false) {
      return "Please enter valid number";
    }
    return null;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: SafeArea(
        child: Form(
          key: logKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(
              height: 50,
            ),
            Align(
              child: SizedBox(
                width: 340,
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: contactController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: Color(0xffF323F4B),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffEE7EB)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffEE7EB)),
                    ),
                    hintText: 'Enter Phone Number',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: contactValidate,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () async {
                if (logKey.currentState!.validate()) {
                  try {
                    SharedPreferences sp =
                        await SharedPreferences.getInstance();
                    sp.setString('contact', contactController.text);

                    await FirebaseAuth.instance
                        .verifyPhoneNumber(
                            verificationCompleted:
                                (PhoneAuthCredential credential) {},
                            verificationFailed: (FirebaseAuthException ex) {},
                            codeSent:
                                (String VarificationId, int? resendtoken) {
                              Get.to(OptScreen(
                                varificationId: VarificationId,
                              ));
                            },
                            codeAutoRetrievalTimeout:
                                (String varificationId) {},
                            phoneNumber: contactController.text.toString())
                        .then((value) {
                      Get.snackbar(
                        'Success',
                        'OTP send on your phone',
                        colorText: Colors.black,
                        backgroundColor: Colors.green,
                        snackPosition: SnackPosition.TOP,
                        onTap: (SnackBar) {},
                      );
                    });
                  } catch (e) {
                    print(e);
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
                child: Center(child: Text("Send")),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
