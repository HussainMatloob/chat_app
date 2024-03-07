import 'dart:io';

import 'package:chat_app/api/api.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/screens/home_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState(); 
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate=false;
  @override


  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(microseconds: 500),(){
      setState(() {
        _isAnimate=true;
      });
    });
  }


  _handleGoogleBtnClick(){

    Dialogs.showProgressBar(context);

    _signInWithGoogle().then((value) async{

      Navigator.pop(context);

      if(value!=null){
        
        if((await APIs.userExists())){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
        }

        else{
          await APIs.createUser().then((value){
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
          });
        }

       Dialogs.showSnackbar(context,'You are Successfully Login','Success') ;
      
      }
    });

  }

  Future<UserCredential?> _signInWithGoogle() async{

  try{
    
   await InternetAddress.lookup('google.com');

   final GoogleSignInAccount? googleUser=await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth=await googleUser?.authentication;
    final credential=GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return await APIs.auth.signInWithCredential(credential);
  }
 catch(e){
           
          Dialogs.showSnackbar(context,'Something went wrong (check Internet!)','Error');
                        return null;

        }
     
  }

  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Well Come to We Chat"),
      ),
      body: Stack(
        children: [
         AnimatedPositioned(
             top: mq.height*.15,
             width: mq.width*.5,
             right:_isAnimate? mq.width*.25:-mq.width*.5,
             duration: Duration(seconds: 1),
             child: Image.asset('images/chat_image.png')),

          Positioned(
              bottom: mq.height*.15,
              left: mq.width*.05,
              width: mq.width*.9,
              height: mq.height*.06,
              child: ElevatedButton.icon(
                  onPressed: (){

                       _handleGoogleBtnClick();

                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green,
                  shape: StadiumBorder(),elevation: 1),
                  icon: Image.asset('images/google.png',height: mq.height*.03,),
                  label: RichText(text: TextSpan(
                      style: TextStyle(color: Colors.black,fontSize: 16),
                      children: [
                    TextSpan(text: 'Signin with '),
                    TextSpan(text: 'Google',style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),))),
        ],
      ),
    );
  }
}