import 'package:chat_app/name_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OptScreen extends StatefulWidget {
  String varificationId;
   OptScreen({super.key,required this.varificationId});

  @override

  State<OptScreen> createState() => _OptScreenState();
}

class _OptScreenState extends State<OptScreen> {

  @override

  String pinCode = '';

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white70,
           body: SingleChildScrollView(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                SizedBox(height: 70,),
                 Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    PinCodeTextField(appContext: context,
                        length: 6,
                    cursorColor: Colors.teal,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    obscuringCharacter: '*',
                    enabled: true,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeColor: Colors.grey,
                      activeFillColor: Colors.teal,
                      inactiveFillColor: Colors.grey,
                      selectedFillColor: Colors.red,
                      inactiveColor: Colors.red,
                      selectedColor: Colors.blue,
                    ),onCompleted: (value) {
                      pinCode=value;
                    },
                    onChanged: (value){

                       
                 
                    }
                    ),
                    ],
                  ),),
                  SizedBox(height: 20,),
                 
                 InkWell(
                  onTap: ()async{
                     
                     try{
                      PhoneAuthCredential credential=await PhoneAuthProvider.credential(verificationId: widget.varificationId, smsCode: pinCode);
                     
                     FirebaseAuth.instance.signInWithCredential(credential).then((value){

                      Get.snackbar('Success','You register successfully',
                      colorText: Colors.black,
                      backgroundColor: Colors.green,
                      snackPosition: SnackPosition.TOP,
                      onTap: (SnackBar){
                      },
                    );

                     }).onError((error, stackTrace) {

                      Get.snackbar('Error',error.toString(),
                      colorText: Colors.black,
                      backgroundColor: Colors.green,
                      snackPosition: SnackPosition.TOP,
                      onTap: (SnackBar){
                      },
                    );

                     });

                     }catch(e)
                     {
                          
                     }
                   
                    Get.to(NameScreen());
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
             
               ],
             ),
           ),
      ),
    );
  }
}