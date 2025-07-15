// lib/app/modules/manage_rooms/controllers/manage_rooms_controller.dart

import 'dart:async'; // <-- IMPORT THIS
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ManageRoomsController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  var isLoading = true.obs;
  var floor1Rooms = <String>[].obs;
  var floor2Rooms = <String>[].obs;

  late DocumentReference _roomDocRef;
  
  // 1. Declare the StreamSubscription
  StreamSubscription<DocumentSnapshot>? _roomSubscription;

  @override
  void onInit() {
    super.onInit();
    _roomDocRef = _firestore.collection('settings').doc('room_list');
    
    // 2. Assign the listener to the subscription variable
    _roomSubscription = _roomDocRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        floor1Rooms.assignAll(List<String>.from(data['lantai_1'] ?? []));
        floor2Rooms.assignAll(List<String>.from(data['lantai_2'] ?? []));
      }
      isLoading.value = false;
    }, onError: (error) {
      // This will now be less likely to fire on logout
      Get.snackbar('Error', 'Failed to load room data: ${error.toString()}');
      isLoading.value = false;
    });
  }

  // 3. Override onClose to cancel the subscription
  @override
  void onClose() {
    _roomSubscription?.cancel();
    super.onClose();
  }


  Future<void> addRoom(int floor, String roomName) async {
    if (roomName.trim().isEmpty) {
      Get.snackbar('Error', 'Room name cannot be empty.');
      return;
    }

    final field = 'lantai_$floor';
    try {
      await _roomDocRef.update({
        field: FieldValue.arrayUnion([roomName.trim()])
      });
      Get.back(); // Close the dialog
      Get.snackbar('Success', 'Room "$roomName" was added successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add room: ${e.toString()}');
    }
  }

  Future<void> deleteRoom(int floor, String roomName) async {
    final field = 'lantai_$floor';
    try {
      await _roomDocRef.update({
        field: FieldValue.arrayRemove([roomName])
      });
      Get.snackbar('Success', 'Room "$roomName" was deleted successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete room: ${e.toString()}');
    }
  }
}