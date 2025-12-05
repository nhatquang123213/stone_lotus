import 'package:get/get.dart';
import 'package:stone_lotus/login.dart';

class RootController extends GetxController{

  bool isAdmin=false;
  UserModel user=UserModel(id: '', email: '', username: '', password: '');

  static RootController get to => Get.find<RootController>();

  void saveCurrentUser(UserModel user) {
    this.user=user;
  }


}