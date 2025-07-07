import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  void signOut() {
    AuthController.instance.signOut();
  }
  
  String get userEmail => AuthController.instance.firebaseUser.value?.email ?? '';
  String get displayName => AuthController.instance.firebaseUser.value?.displayName ?? 'User';
}