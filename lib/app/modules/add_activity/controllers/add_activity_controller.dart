import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sppdn/app/modules/auth/controllers/auth_controller.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AddActivityController extends GetxController {
  // State
  RxBool isLoading = false.obs;
  Rxn<File> imageFile = Rxn<File>();
  Rxn<String> selectedRoom = Rxn<String>();

  // Dependencies
  final formKey = GlobalKey<FormState>();
  final _authController = AuthController.instance;
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;

  // Data
  late int floor;
  late List<String> roomList;
  String get officerName => _authController.firebaseUser.value?.displayName ?? 'Nama Tidak Ditemukan';

  // Daftar ruangan berdasarkan lantai
  final Map<int, List<String>> _allRooms = {
    1: ['R. DOKTER', 'R. LABELING', 'R. PPNPN', 'LORONG LAB', 'TOILET LOBBY', 'R. SPEKTOMETER', 'R. KIMIA FISIK', 'RUANG TRANSIT', 'LOBBY DEPAN', 'TERAS', 'TOILET KIMBAS COWO', 'TOILET KIMBAS CEWE', 'R. KIMBAS', 'R. BAHAN KIMIA', 'R. ALAT GELAS', 'R. XRF', 'R. ASAM', 'R. PREPARASI', 'R. TIMBANG', 'R. OES', 'R. THREMAL', 'R. KROMATOGRAFI'],
    2: ['TOILET COWO LT 2', 'R. KA BALAI', 'R. TEKNIS II', 'R. HUMAS', 'TOILET KA BALAI', 'LORONG ATAS', 'TANGGA', 'R. RAPAT', 'R. TEKNIS I', 'R. SBU', 'R. PE', 'R. ABW', 'MUSHOLLA', 'TOILET CEWE LT 2', 'R. MAKAN', 'R. ANAK DAN LAKTASI', 'GUDANG ARSIP', 'PANTRI']
  };

  @override
  void onInit() {
    super.onInit();
    // Mengambil argumen lantai yang dikirim dari HomeController
    floor = Get.arguments as int;
    // Mengisi daftar ruangan sesuai lantai yang dipilih
    roomList = _allRooms[floor] ?? [];
  }

  // Fungsi untuk mengambil gambar dari kamera
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
    }
  }

  // Fungsi untuk mengompres gambar
  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.absolute.path, "${DateTime.now().millisecondsSinceEpoch}.jpg");

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60, // Kualitas kompresi (0-100)
    );

    return File(result!.path);
  }

  // Fungsi utama untuk menyimpan aktivitas
  Future<void> saveActivity() async {
    // Validasi form
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
      // 1. Kompres gambar
      final compressedImage = await _compressImage(imageFile.value!);

      // 2. Upload gambar ke Firebase Storage
      final String fileName = 'activity_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child('activity_photos').child(fileName);
      
      // **PERUBAHAN DI SINI: Tambahkan SettableMetadata()**
      final UploadTask uploadTask = storageRef.putFile(compressedImage, SettableMetadata(contentType: 'image/jpeg'));
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // 3. Simpan data ke Firestore
      await _firestore.collection('activities').add({
        'officerName': officerName,
        'officerUid': _authController.firebaseUser.value!.uid,
        'room': selectedRoom.value,
        'floor': floor,
        'imageUrl': downloadUrl,
        'createdAt': FieldValue.serverTimestamp(), // Tanggal dan jam dibuat oleh server
      });

      Get.back(); // Kembali ke halaman home
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