import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class AddActivityDialog extends GetView<HomeController> {
  const AddActivityDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan AlertDialog sebagai dasar popup yang sudah familiar
    return AlertDialog(
      // Memberi sudut tumpul agar sesuai dengan tema aplikasi
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      // Menghapus padding default agar konten bisa menempel ke tepi
      contentPadding: const EdgeInsets.all(24.0),
      // Menggunakan Column untuk menyusun konten secara vertikal
      content: Column(
        mainAxisSize: MainAxisSize.min, // Membuat tinggi dialog pas dengan konten
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Judul Dialog
          const Text(
            'Tambah Kegiatan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Deskripsi singkat
          Text(
            'Pilih lantai untuk melanjutkan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Pilihan Lantai 1
          ElevatedButton(
            onPressed: controller.onLantai1Selected,
            style: _buttonStyle(),
            child: const Text('Lantai 1'),
          ),
          const SizedBox(height: 12),

          // Tombol Pilihan Lantai 2
          ElevatedButton(
            onPressed: controller.onLantai2Selected,
            style: _buttonStyle(),
            child: const Text('Lantai 2'),
          ),
        ],
      ),
    );
  }

  // Helper untuk styling tombol agar konsisten
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}