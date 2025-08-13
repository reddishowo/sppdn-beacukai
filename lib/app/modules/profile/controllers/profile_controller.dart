// lib/app/modules/profile/controllers/profile_controller.dart

import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final _authController = AuthController.instance;

  // **PERUBAHAN: State untuk dialog edit telah dihapus**
  // late TextEditingController nameController;
  // final formKey = GlobalKey<FormState>();

  String get userEmail => _authController.firebaseUser.value?.email ?? 'Tidak ada email';
  String get displayName => _authController.firebaseUser.value?.displayName ?? 'Pengguna';
  
  // **PERUBAHAN: Tidak perlu lagi inisialisasi/dispose state edit**


  void signOut() {
    _authController.signOut();
  }

  // **PERUBAHAN: Fungsi untuk menyimpan perubahan nama telah dihapus**
}