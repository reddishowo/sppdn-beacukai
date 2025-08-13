import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ExportController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  var isLoading = true.obs;
  var userList = <Map<String, dynamic>>[].obs;
  var isExporting = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchUsersWithActivities();
  }

  Future<void> _fetchUsersWithActivities() async {
    // This logic is correct and does not need to change.
    isLoading.value = true;
    try {
      final activitiesSnapshot = await _firestore.collection('activities').get();
      if (activitiesSnapshot.docs.isEmpty) {
        isLoading.value = false;
        return;
      }
      final userIds = activitiesSnapshot.docs
          .map((doc) => doc.data()['officerUid'] as String)
          .toSet();

      if (userIds.isNotEmpty) {
        final usersSnapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: userIds.toList())
            .get();

        userList.assignAll(usersSnapshot.docs.map((doc) => {
              'uid': doc.id,
              'name': doc.data()['name'] ?? 'No Name',
              'email': doc.data()['email'] ?? 'No Email',
            }));
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat daftar pengguna: ${e.toString()}',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Exports user data using the modern, permission-less approach.
  Future<void> exportUserData(String userId, String userName) async {
    isExporting.value = userId;
    try {
      // 1. Fetch activities (no change)
      final activitiesSnapshot = await _firestore
          .collection('activities')
          .where('officerUid', isEqualTo: userId)
          .orderBy('activityTimestamp', descending: true)
          .get();
          
      if (activitiesSnapshot.docs.isEmpty) {
         Get.snackbar('Data Kosong', 'Pengguna ini tidak memiliki data kegiatan untuk diekspor.');
         isExporting.value = '';
         return;
      }

      // 2. Create Excel file (no change)
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Laporan Kegiatan'];
      sheetObject.appendRow([
        TextCellValue('Nama Petugas'), TextCellValue('Tanggal / Jam'),
        TextCellValue('Ruangan'), TextCellValue('Keterangan'),
      ]);
      for (var doc in activitiesSnapshot.docs) {
        final data = doc.data();
        final timestamp = data['activityTimestamp'] as Timestamp;
        final formattedDateTime = DateFormat('dd-MM-yyyy HH:mm').format(timestamp.toDate());
        sheetObject.appendRow([
          TextCellValue(data['officerName'] ?? ''), TextCellValue(formattedDateTime),
          TextCellValue(data['room'] ?? ''), TextCellValue(data['keterangan'] ?? ''),
        ]);
      }
      
      // --- 3. SAVE TO APP'S PRIVATE DIRECTORY (NO PERMISSION NEEDED) ---
      // This gets a directory that is private to your app, but accessible by other apps via the OS.
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Laporan_${userName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
      final fileBytes = excel.save();

      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes, flush: true);
        
        // --- 4. USE OPENFILEX TO PROMPT THE USER ---
        // This will trigger an "Open with..." dialog on the user's phone.
        final result = await OpenFilex.open(filePath);

        // You can check the result and give feedback.
        if (result.type != ResultType.done) {
          Get.snackbar('Tidak Dapat Membuka File', 'Tidak ditemukan aplikasi untuk membuka file Excel. Harap simpan file secara manual dari: ${directory.path}');
        } else {
          // You can optionally add a success snackbar here if you want.
          Get.snackbar('Berhasil', 'Membuka file Excel...');
        }
      }
    } catch (e) {
      Get.snackbar('Ekspor Gagal', 'Terjadi kesalahan: ${e.toString()}',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isExporting.value = '';
    }
  }
}