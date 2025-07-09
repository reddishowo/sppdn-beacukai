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
  late List<String> roomList;
  String get officerName => _authController.firebaseUser.value?.displayName ?? 'Nama Tidak Ditemukan';

  // Daftar ruangan (tetap sama)
  final Map<int, List<String>> _allRooms = {
    1: ['R. DOKTER', 'R. LABELING', 'R. PPNPN', 'LORONG LAB', 'TOILET LOBBY', 'R. SPEKTOMETER', 'R. KIMIA FISIK', 'RUANG TRANSIT', 'LOBBY DEPAN', 'TERAS', 'TOILET KIMBAS COWO', 'TOILET KIMBAS CEWE', 'R. KIMBAS', 'R. BAHAN KIMIA', 'R. ALAT GELAS', 'R. XRF', 'R. ASAM', 'R. PREPARASI', 'R. TIMBANG', 'R. OES', 'R. THREMAL', 'R. KROMATOGRAFI'],
    2: ['TOILET COWO LT 2', 'R. KA BALAI', 'R. TEKNIS II', 'R. HUMAS', 'TOILET KA BALAI', 'LORONG ATAS', 'TANGGA', 'R. RAPAT', 'R. TEKNIS I', 'R. SBU', 'R. PE', 'R. ABW', 'MUSHOLLA', 'TOILET CEWE LT 2', 'R. MAKAN', 'R. ANAK DAN LAKTASI', 'GUDANG ARSIP', 'PANTRI']
  };

  @override
  void onInit() {
    super.onInit();
    floor = Get.arguments as int;
    roomList = _allRooms[floor] ?? [];
  }

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

  // **FUNGSI UPLOAD KE IMGBB**
  Future<String?> _uploadToImgBB(File image) async {
    // API Key Anda sudah dimasukkan di sini.
    const String apiKey = '505a48d52595aab0278a36921434b2dc';

    //
    // !!! BLOK IF YANG BERMASALAH SUDAH DIHAPUS !!!
    //

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
          // Memberikan pesan error yang lebih jelas dari API
          final errorMessage = decodedBody['error']['message'];
          Get.snackbar('Error API ImgBB', errorMessage, snackPosition: SnackPosition.BOTTOM);
          print("ImgBB API Error: $errorMessage");
          return null;
        }
      } else {
        // Memberikan pesan error yang lebih jelas untuk status code HTTP
        Get.snackbar('Error Upload', 'Gagal terhubung ke server. Status: ${response.statusCode}', snackPosition: SnackPosition.BOTTOM);
        print("HTTP Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      Get.snackbar('Error Jaringan', 'Terjadi kesalahan: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
      print("Error saat mengupload ke ImgBB: $e");
      return null;
    }
  }

  // Logika penyimpanan aktivitas (TETAP SAMA, TIDAK PERLU DIUBAH)
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
        // Pesan error sudah ditampilkan dari dalam _uploadToImgBB
        // Cukup hentikan prosesnya di sini.
        isLoading.value = false;
        return;
      }
      
      await _firestore.collection('activities').add({
        'officerName': officerName,
        'officerUid': _authController.firebaseUser.value!.uid,
        'room': selectedRoom.value,
        'floor': floor,
        'imageUrl': imageUrl,
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