// File: /sppdn/lib/app/modules/home/bindings/home_binding.dart

import 'package:get/get.dart';
import 'package:sppdn/app/modules/profile/controllers/profile_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Controller utama untuk kerangka home
    Get.lazyPut<HomeController>(() => HomeController());
    // Controller untuk tab profil
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}