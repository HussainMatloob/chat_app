import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class Dialogs{

    static void showProgressBar(BuildContext context ){

    showDialog(context:context,builder:(_)=>Center(child: CircularProgressIndicator(),));

    }
    

  static void showSnackbar(BuildContext context,String message,String TopMessage){

     Get.snackbar(TopMessage,message,
                          colorText: Colors.black,
                          backgroundColor: Colors.green,
                          snackPosition: SnackPosition.TOP,
                          onTap: (SnackBar){

                          },
                    );
                      }

}

 