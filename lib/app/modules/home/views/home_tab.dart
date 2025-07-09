import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/home_controller.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildHeader(),
          ),
          // Judul List
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Riwayat Kegiatan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          // Daftar Kegiatan dari Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: controller.activityStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Terjadi kesalahan'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Belum ada kegiatan.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  );
                }

                final docs = snapshot.data!.docs;
                return _buildGroupedListView(docs);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Header (tetap sama)
  Widget _buildHeader() {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Halo,', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          Text(controller.displayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        ]),
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade600),
          onPressed: () => Get.snackbar('Notifikasi', 'Tidak ada notifikasi baru.'),
        ),
      ],
    ));
  }

  // Helper untuk memformat Timestamp ke String tanggal
  String _formatDate(Timestamp timestamp) {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(timestamp.toDate());
  }

  // Helper untuk mengecek apakah dua tanggal berada di hari yang sama
  bool _isSameDay(Timestamp? a, Timestamp b) {
    if (a == null) return false;
    final dateA = a.toDate();
    final dateB = b.toDate();
    return dateA.year == dateB.year && dateA.month == dateB.month && dateA.day == dateB.day;
  }

  // Widget utama yang membangun ListView dengan pengelompokan tanggal
  Widget _buildGroupedListView(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      itemCount: docs.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>;
        final currentTimestamp = data['createdAt'] as Timestamp;
        
        // Cek apakah perlu menampilkan header tanggal
        final bool showDateHeader;
        if (index == 0) {
          showDateHeader = true;
        } else {
          final prevData = docs[index - 1].data() as Map<String, dynamic>;
          final prevTimestamp = prevData['createdAt'] as Timestamp;
          showDateHeader = !_isSameDay(prevTimestamp, currentTimestamp);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  _formatDate(currentTimestamp),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                ),
              ),
            _buildActivityCard(data),
          ],
        );
      },
    );
  }

  // Widget untuk menampilkan satu kartu aktivitas
  Widget _buildActivityCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Gambar Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: data['imageUrl'] ?? '',
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade200),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(width: 12),
            // Detail Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['room'] ?? 'Ruangan Tidak Ada',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Petugas: ${data['officerName'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}