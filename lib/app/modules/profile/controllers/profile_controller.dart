// File: /sppdn/lib/app/modules/profile/controllers/profile_controller.dart

import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final _authController = AuthController.instance;

  String get userEmail => _authController.firebaseUser.value?.email ?? 'Tidak ada email';
  String get displayName => _authController.firebaseUser.value?.displayName ?? 'Pengguna';

  void signOut() {
    _authController.signOut();
  }
}