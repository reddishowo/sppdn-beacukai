import 'package:get/get.dart';
import '../controllers/add_activity_controller.dart';

class AddActivityBinding extends Bindings {
  @override
  void dependencies() {
    // Menggunakan fenix: true agar controller tidak dihapus saat halaman ditutup,
    // tetapi akan dibuat ulang saat halaman diakses kembali.
    Get.lazyPut<AddActivityController>(() => AddActivityController(), fenix: true);
  }
}