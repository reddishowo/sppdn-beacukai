import 'package:flutter/material.dart'; // <-- Tambahkan import ini
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final _authController = AuthController.instance;

  // State untuk dialog edit
  late TextEditingController nameController;
  final formKey = GlobalKey<FormState>();

  String get userEmail => _authController.firebaseUser.value?.email ?? 'Tidak ada email';
  String get displayName => _authController.firebaseUser.value?.displayName ?? 'Pengguna';

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi controller dengan nama saat ini
    nameController = TextEditingController(text: displayName);
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  void signOut() {
    _authController.signOut();
  }

  // **FUNGSI UNTUK MENYIMPAN PERUBAHAN NAMA**
  void saveProfileChanges() {
    if (formKey.currentState!.validate()) {
      // Panggil fungsi di AuthController
      _authController.updateUserName(nameController.text);
    }
  }
}