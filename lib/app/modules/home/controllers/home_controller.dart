import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sppdn/app/modules/profile/views/profile_view.dart';
import 'package:sppdn/app/routes/app_pages.dart';
import '../../auth/controllers/auth_controller.dart';
import '../views/home_tab.dart';
import '../views/widgets/add_activity_dialog.dart';

class HomeController extends GetxController {
  var tabIndex = 0.obs;

  String get displayName => AuthController.instance.firebaseUser.value?.displayName ?? 'Pengguna';

  final pages = [
    const HomeTab(),
    const ProfileView(),
  ];

  // STREAM UNTUK MENGAMBIL DATA KEGIATAN DARI FIRESTORE
  final Stream<QuerySnapshot> activityStream = FirebaseFirestore.instance
      .collection('activities')
      .orderBy('createdAt', descending: true)
      .snapshots();

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  void onAddButtonPressed() {
    Get.dialog(
      const AddActivityDialog(),
      barrierDismissible: true,
    );
  }

  // UBAH FUNGSI INI UNTUK NAVIGASI KE FORM
  void onLantai1Selected() {
    Get.back(); // Tutup dialog
    Get.toNamed(Routes.ADD_ACTIVITY, arguments: 1); // Kirim argumen lantai 1
  }

  // UBAH FUNGSI INI UNTUK NAVIGASI KE FORM
  void onLantai2Selected() {
    Get.back(); // Tutup dialog
    Get.toNamed(Routes.ADD_ACTIVITY, arguments: 2); // Kirim argumen lantai 2
  }
}