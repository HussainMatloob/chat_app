import 'package:get/get.dart';

class imageUploadingController extends GetxController {
  bool isUploadingStatus = false;

  imageUpload(bool value) {
    isUploadingStatus = !value;
    update();
  }
}
