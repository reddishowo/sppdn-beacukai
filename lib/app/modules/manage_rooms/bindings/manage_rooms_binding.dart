import 'package:get/get.dart';
import '../controllers/manage_rooms_controller.dart';

class ManageRoomsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageRoomsController>(
      () => ManageRoomsController(),
    );
  }
}