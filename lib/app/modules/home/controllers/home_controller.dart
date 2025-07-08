// File: /sppdn/lib/app/modules/home/controllers/home_controller.dart

import 'package:get/get.dart';
import 'package:sppdn/app/modules/profile/views/profile_view.dart';
import '../../auth/controllers/auth_controller.dart';
import '../views/home_tab.dart';

class HomeController extends GetxController {
  // Mengelola tab yang sedang aktif
  var tabIndex = 0.obs;

  // Mendapatkan nama user dari AuthController
  String get displayName => AuthController.instance.firebaseUser.value?.displayName ?? 'Selamat Datang';

  // Daftar halaman/widget untuk navigasi
  final pages = [
    const HomeTab(),
    const ProfileView(),
  ];

  // Fungsi untuk mengubah tab
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  // Fungsi untuk tombol FAB (+)
  void onAddButtonPressed() {
    Get.snackbar(
      'Fitur Mendatang',
      'Fungsionalitas tambah data akan segera hadir!',
      snackPosition: SnackPosition.TOP,
    );
  }
}