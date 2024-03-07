import 'package:get/get.dart';

class EmojiController extends GetxController {
  bool showEmoji = false;

  emoji(bool value) {
    showEmoji = !value;
    update();
  }
}
