import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ManageRoomsController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  var isLoading = true.obs;
  var floor1Rooms = <String>[].obs;
  var floor2Rooms = <String>[].obs;

  late DocumentReference _roomDocRef;

  @override
  void onInit() {
    super.onInit();
    _roomDocRef = _firestore.collection('settings').doc('room_list');
    
    // Listen to real-time changes
    _roomDocRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        floor1Rooms.assignAll(List<String>.from(data['lantai_1'] ?? []));
        floor2Rooms.assignAll(List<String>.from(data['lantai_2'] ?? []));
      }
      isLoading.value = false;
    }, onError: (error) {
      Get.snackbar('Error', 'Gagal memuat data ruangan: ${error.toString()}');
      isLoading.value = false;
    });
  }

  Future<void> addRoom(int floor, String roomName) async {
    if (roomName.trim().isEmpty) {
      Get.snackbar('Error', 'Nama ruangan tidak boleh kosong.');
      return;
    }

    final field = 'lantai_$floor';
    try {
      await _roomDocRef.update({
        field: FieldValue.arrayUnion([roomName.trim()])
      });
      Get.back(); // Close the dialog
      Get.snackbar('Sukses', 'Ruangan "$roomName" berhasil ditambahkan.');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambah ruangan: ${e.toString()}');
    }
  }

  Future<void> deleteRoom(int floor, String roomName) async {
    final field = 'lantai_$floor';
    try {
      await _roomDocRef.update({
        field: FieldValue.arrayRemove([roomName])
      });
      Get.snackbar('Sukses', 'Ruangan "$roomName" berhasil dihapus.');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus ruangan: ${e.toString()}');
    }
  }
}