// File: /sppdn/lib/app/modules/home/views/home_tab.dart (Versi Diperbarui)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengganti Scaffold dengan ListView agar menjadi bagian dari HomeView
    // dan bisa di-scroll. SafeArea memastikan konten tidak terhalang status bar.
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Header Baru yang Lebih Modern
          _buildHeader(),
          const SizedBox(height: 24),

          // 3. Daftar Aktivitas Terkini
          _buildRecentActivity(),
        ],
      ),
    );
  }

  // Widget untuk Header
  Widget _buildHeader() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Halo, Selamat Datang',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Text(
                controller.displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade600),
            onPressed: () {
              Get.snackbar('Notifikasi', 'Tidak ada notifikasi baru.');
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk Daftar Aktivitas Terkini
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktivitas Terkini',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Item-item dummy untuk contoh
        _buildActivityTile(
          title: 'Perjalanan Dinas ke Jakarta',
          subtitle: '18 Agu 2023 - Disetujui',
          statusColor: Colors.green,
        ),
        _buildActivityTile(
          title: 'Rapat Koordinasi di Bandung',
          subtitle: '15 Agu 2023 - Menunggu',
          statusColor: Colors.orange,
        ),
        _buildActivityTile(
          title: 'Inspeksi Lapangan di Surabaya',
          subtitle: '12 Agu 2023 - Ditolak',
          statusColor: Colors.red,
        ),
      ],
    );
  }

  // Helper untuk membuat satu item Aktivitas Terkini
  Widget _buildActivityTile({
    required String title,
    required String subtitle,
    required Color statusColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: statusColor, radius: 5),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}