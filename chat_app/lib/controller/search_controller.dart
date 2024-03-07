import 'package:get/get.dart';

class SearchController extends GetxController {
  bool _isSearching = false;

  SearchName(bool value) {
    _isSearching = !value;
  }
}
