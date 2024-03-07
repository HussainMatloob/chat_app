import 'package:chat_app/models/chat_user.dart';
import 'package:get/get.dart';

class SelectedContactController extends GetxController {
  bool searching = false;
  List<ChatUser> _searchListUsers = [];
  List<ChatUser> get searchListUsers => _searchListUsers;
  int get lengthOfSearchListUsers => _searchListUsers.length;

  searchByName(bool value) {
    searching = !value;
    update();
  }

  addSearchUserInList(indexValue) {
    _searchListUsers.add(indexValue);
    update();
  }

  searchListClear() {
    _searchListUsers.clear();
    update();
  }
}
