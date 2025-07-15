// lib/app/modules/add_activity/controllers/add_activity_controller.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sppdn/app/modules/auth/controllers/auth_controller.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddActivityController extends GetxController {
  // State
  RxBool isLoading = false.obs;
  Rxn<File> imageFile = Rxn<File>();
  Rxn<String> selectedRoom = Rxn<String>();

  // Dependencies
  final formKey = GlobalKey<FormState>();
  final _authController = AuthController.instance;
  final _picker = ImagePicker();
  final _firestore = FirebaseFirestore.instance;

  // Data
  late int floor;
  late DateTime activityTimestamp;
  String get officerName => _authController.firebaseUser.value?.displayName ?? 'Nama Tidak Ditemukan';

  // **PERUBAHAN: roomList sekarang reaktif**
  var roomList = <String>[].obs;

  // Formatters
  String get formattedDate => DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(activityTimestamp);
  String get formattedTime => DateFormat('HH:mm', 'id_ID').format(activityTimestamp);

  // **PERUBAHAN: Hapus daftar ruangan statis**
  // final Map<int, List<String>> _allRooms = { ... };

  @override
  void onInit() {
    super.onInit();
    floor = Get.arguments as int;
    activityTimestamp = DateTime.now();
    // **PERUBAHAN: Panggil fungsi untuk mengambil data ruangan dari Firestore**
    _fetchRooms();
  }

  // **FUNGSI BARU: Mengambil daftar ruangan dari Firestore**
  Future<void> _fetchRooms() async {
    // Tampilkan loading di dropdown
    isLoading.value = true; 
    try {
      final doc = await _firestore.collection('settings').doc('room_list').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final floorKey = 'lantai_$floor';
        if (data.containsKey(floorKey)) {
          // Update daftar ruangan yang reaktif
          roomList.assignAll(List<String>.from(data[floorKey]));
        } else {
          Get.snackbar('Error Data', 'Data ruangan untuk lantai $floor tidak ditemukan di database.');
        }
      } else {
        Get.snackbar('Error Konfigurasi', 'Dokumen konfigurasi ruangan tidak ditemukan.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data ruangan: ${e.toString()}');
    } finally {
      // Sembunyikan loading
      isLoading.value = false;
    }
  }

  // ... (Sisa fungsi: pickImage, _compressImage, _uploadToImgBB, saveActivity, cancel tidak berubah)
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
    }
  }

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.absolute.path, "${DateTime.now().millisecondsSinceEpoch}.jpg");

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
    );

    return File(result!.path);
  }

  Future<String?> _uploadToImgBB(File image) async {
    const String apiKey = '505a48d52595aab0278a36921434b2dc';

    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decodedBody = json.decode(responseBody);
        if (decodedBody['success'] == true) {
          return decodedBody['data']['url'];
        } else {
          final errorMessage = decodedBody['error']['message'];
          Get.snackbar('Error API ImgBB', errorMessage, snackPosition: SnackPosition.BOTTOM);
          return null;
        }
      } else {
        Get.snackbar('Error Upload', 'Gagal terhubung ke server. Status: ${response.statusCode}', snackPosition: SnackPosition.BOTTOM);
        return null;
      }
    } catch (e) {
      Get.snackbar('Error Jaringan', 'Terjadi kesalahan: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }
  
  Future<void> saveActivity() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      Get.snackbar('Error', 'Harap lengkapi semua data yang diperlukan.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (imageFile.value == null) {
      Get.snackbar('Error', 'Foto kegiatan wajib diisi.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final compressedImage = await _compressImage(imageFile.value!);
      final String? imageUrl = await _uploadToImgBB(compressedImage);

      if (imageUrl == null) {
        isLoading.value = false;
        return;
      }
      
      await _firestore.collection('activities').add({
        'officerName': officerName,
        'officerUid': _authController.firebaseUser.value!.uid,
        'room': selectedRoom.value,
        'floor': floor,
        'imageUrl': imageUrl,
        'activityTimestamp': Timestamp.fromDate(activityTimestamp),
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.back();
      Get.snackbar('Sukses', 'Kegiatan berhasil disimpan.', snackPosition: SnackPosition.BOTTOM);

    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan kegiatan: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void cancel() {
    Get.back();
  }
}