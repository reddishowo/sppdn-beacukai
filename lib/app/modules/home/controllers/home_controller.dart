import 'package:get/get.dart';
import 'package:sppdn/app/modules/profile/views/profile_view.dart';
import '../../auth/controllers/auth_controller.dart';
import '../views/home_tab.dart';
// ** 1. IMPOR WIDGET DIALOG YANG BARU **
import '../views/widgets/add_activity_dialog.dart';

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

  // ** 2. UBAH FUNGSI TOMBOL FAB UNTUK MENAMPILKAN DIALOG **
  void onAddButtonPressed() {
    // Menggunakan Get.dialog untuk menampilkan popup kustom kita
    Get.dialog(
      const AddActivityDialog(),
      // Mencegah dialog ditutup saat mengetuk area di luar dialog
      barrierDismissible: true, 
    );
  }

  // ** 3. TAMBAHKAN FUNGSI UNTUK MENANGANI PILIHAN DARI DIALOG **

  // Fungsi yang akan dijalankan saat tombol "Lantai 1" ditekan
  void onLantai1Selected() {
    // 1. Tutup dialog terlebih dahulu
    Get.back(); 
    
    // 2. Lakukan aksi selanjutnya (untuk sekarang, tampilkan Snackbar)
    Get.snackbar(
      'Aksi Dipilih',
      'Form tambah kegiatan untuk Lantai 1 akan ditampilkan.',
      snackPosition: SnackPosition.BOTTOM,
    );
    
    // Di sini Anda bisa menambahkan navigasi ke halaman form, misalnya:
    // Get.toNamed('/add-activity-form', arguments: {'floor': 1});
  }

  // Fungsi yang akan dijalankan saat tombol "Lantai 2" ditekan
  void onLantai2Selected() {
    // 1. Tutup dialog terlebih dahulu
    Get.back();
    
    // 2. Lakukan aksi selanjutnya (untuk sekarang, tampilkan Snackbar)
    Get.snackbar(
      'Aksi Dipilih',
      'Form tambah kegiatan untuk Lantai 2 akan ditampilkan.',
      snackPosition: SnackPosition.BOTTOM,
    );
    
    // Di sini Anda bisa menambahkan navigasi ke halaman form, misalnya:
    // Get.toNamed('/add-activity-form', arguments: {'floor': 2});
  }
}