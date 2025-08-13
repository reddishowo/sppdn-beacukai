import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // <-- THIS IS THE LINE YOU NEED TO ADD
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sppdn/app/modules/auth/controllers/auth_controller.dart';

class AddActivityController extends GetxController {
  // --- START: IMAGEKIT CONFIGURATION ---
  // WARNING: Storing your private key in the app is a security risk.
  // ignore: unused_field
  final String _imageKitPublicKey = "public_xRFYsXAzsF/dD3ODvbb9wGPX3m4=";
  final String _imageKitPrivateKey = "private_nzy2ayDdr+hBnvuWhE2+KcTSmOk=";
  final String _imageKitUploadUrl = "https://upload.imagekit.io/api/v1/files/upload";
  // --- END: IMAGEKIT CONFIGURATION ---


  // State
  RxBool isLoading = false.obs;
  Rxn<File> imageFile = Rxn<File>();
  Rxn<String> selectedRoom = Rxn<String>();

  // Dependencies
  final formKey = GlobalKey<FormState>();
  final keteranganController = TextEditingController();
  final _authController = AuthController.instance;
  final _picker = ImagePicker();
  final _firestore = FirebaseFirestore.instance;

  // Data
  late int floor;
  late DateTime activityTimestamp;
  String get officerName =>
      _authController.firebaseUser.value?.displayName ?? 'Nama Tidak Ditemukan';

  var roomList = <String>[].obs;

  // Formatters
  String get formattedDate =>
      DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(activityTimestamp);
  String get formattedTime => DateFormat('HH:mm', 'id_ID').format(activityTimestamp);

  @override
  void onInit() {
    super.onInit();
    floor = Get.arguments as int;
    activityTimestamp = DateTime.now();
    _fetchRooms();
  }

  @override
  void onClose() {
    keteranganController.dispose();
    super.onClose();
  }

  Future<void> _fetchRooms() async {
    // This function remains the same
    isLoading.value = true;
    try {
      final doc =
          await _firestore.collection('settings').doc('room_list').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final floorKey = 'lantai_$floor';
        if (data.containsKey(floorKey)) {
          roomList.assignAll(List<String>.from(data[floorKey]));
        } else {
          Get.snackbar('Error Data',
              'Data ruangan untuk lantai $floor tidak ditemukan di database.');
        }
      } else {
        Get.snackbar('Error Konfigurasi',
            'Dokumen konfigurasi ruangan tidak ditemukan.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data ruangan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    // This function remains the same
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
    }
  }

  Future<File> _compressImage(File file) async {
    // This function remains the same
    final dir = await getTemporaryDirectory();
    final targetPath =
        p.join(dir.absolute.path, "${DateTime.now().millisecondsSinceEpoch}.jpg");

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
    );

    return File(result!.path);
  }

  /// Uploads the selected image to ImageKit.io using Basic Authentication.
  Future<String?> _uploadToImageKit(File image) async {
    // Use Basic Authentication with the private key as the username.
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$_imageKitPrivateKey:'))}';
    
    // Create the multipart request.
    var request = http.MultipartRequest('POST', Uri.parse(_imageKitUploadUrl));

    // Add the authentication header.
    request.headers['Authorization'] = basicAuth;

    // Define the filename.
    final fileName = p.basename(image.path);

    // Add the image file to the request.
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // Field name expected by the ImageKit API
        image.path,
      ),
    );

    // Add other required fields.
    request.fields['fileName'] = fileName;
    request.fields['folder'] = '/sppdn_activities';
    request.fields['useUniqueFileName'] = 'true';

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url']; // Return the hosted image URL
      } else {
        Get.snackbar('Error Upload', 'Gagal mengunggah gambar: ${response.body}');
        return null;
      }
    } catch (e) {
      Get.snackbar('Error Jaringan', 'Gagal terhubung ke server upload: $e');
      return null;
    }
  }

  Future<void> saveActivity() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      Get.snackbar('Error', 'Harap lengkapi semua data yang diperlukan.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (imageFile.value == null) {
      Get.snackbar('Error', 'Foto kegiatan wajib diisi.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final compressedImage = await _compressImage(imageFile.value!);
      
      // Call the upload function.
      final String? imageUrl = await _uploadToImageKit(compressedImage);

      if (imageUrl == null) {
        // Error is shown in the upload function, so just stop here.
        isLoading.value = false;
        return;
      }

      await _firestore.collection('activities').add({
        'officerName': officerName,
        'officerUid': _authController.firebaseUser.value!.uid,
        'room': selectedRoom.value,
        'floor': floor,
        'keterangan': keteranganController.text.trim(),
        'imageUrl': imageUrl,
        'activityTimestamp': Timestamp.fromDate(activityTimestamp),
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.back();
      Get.snackbar('Sukses', 'Kegiatan berhasil disimpan.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan kegiatan: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void cancel() {
    Get.back();
  }
}