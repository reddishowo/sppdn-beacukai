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
    return Scaffold( // Bungkus dengan Scaffold agar bisa pakai RefreshIndicator
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Logika refresh, bisa dibiarkan kosong untuk sekedar memicu re-fetch dari StreamBuilder
            // atau panggil fungsi di controller jika ada.
          },
          color: Colors.blue.shade600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildHeader(),
              ),
              // Judul List
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Riwayat Kegiatan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF333333))),
              ),
              const SizedBox(height: 12),
              // Daftar Kegiatan dari Firestore
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: controller.activityStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return _buildErrorState('Terjadi kesalahan: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState();
                    }

                    final docs = snapshot.data!.docs;
                    return _buildGroupedListView(docs);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PERUBAHAN: Header menjadi kartu selamat datang yang lebih personal
  Widget _buildHeader() {
    return Obx(() {
      // Ambil inisial dari nama
      final String displayName = controller.displayName;
      final String initials = displayName.isNotEmpty
          ? displayName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
          : 'U';

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo,' ' Selamat Datang!', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(displayName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.blue.withOpacity(0.2),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      );
    });
  }
  
  // PERUBAHAN: Helper baru untuk tanggal relatif (Hari Ini, Kemarin)
  String _getFormattedDateHeader(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

    if (DateTime(date.year, date.month, date.day) == today) {
      return 'Hari Ini';
    } else if (DateTime(date.year, date.month, date.day) == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    }
  }

  bool _isSameDay(Timestamp? a, Timestamp b) {
    if (a == null) return false;
    final dateA = a.toDate();
    final dateB = b.toDate();
    return dateA.year == dateB.year && dateA.month == dateB.month && dateA.day == dateB.day;
  }

  Widget _buildGroupedListView(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      itemCount: docs.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>;
        
        // Handle jika createdAt null (meskipun jarang)
        if (data['createdAt'] == null) return const SizedBox.shrink();
        final currentTimestamp = data['createdAt'] as Timestamp;
        
        final bool showDateHeader;
        if (index == 0) {
          showDateHeader = true;
        } else {
          final prevData = docs[index - 1].data() as Map<String, dynamic>;
          final prevTimestamp = prevData['createdAt'] as Timestamp?;
          showDateHeader = !_isSameDay(prevTimestamp, currentTimestamp);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader)
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 12.0, left: 4.0),
                child: Text(
                  _getFormattedDateHeader(currentTimestamp),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 16),
                ),
              ),
            _buildActivityCard(data),
          ],
        );
      },
    );
  }

  // PERUBAHAN: Kartu aktivitas yang didesain ulang total
  Widget _buildActivityCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Aksi saat kartu ditekan, misalnya ke halaman detail
          Get.snackbar('Info', 'Detail untuk ruangan ${data['room'] ?? ''}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Gambar Thumbnail dengan border
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: CachedNetworkImage(
                  imageUrl: data['imageUrl'] ?? '',
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(color: Colors.red.shade50),
                    child: const Icon(Icons.broken_image, color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Detail Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data['room'] ?? 'Ruangan tidak spesifik',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5, color: Color(0xFF222222)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            data['officerName'] ?? 'Petugas tidak diketahui',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Indikator panah
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk state kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Belum ada kegiatan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Tekan tombol + untuk menambah kegiatan baru.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600), textAlign: TextAlign.center),
        ],
      ),
    );
  }
  
  // Helper untuk state error
  Widget _buildErrorState(String message) {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          const Text('Oops! Terjadi Masalah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(message, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}