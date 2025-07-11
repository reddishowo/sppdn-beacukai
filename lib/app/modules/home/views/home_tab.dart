import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart'; // <-- TAMBAHKAN IMPORT INI
import '../controllers/home_controller.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          color: Colors.blue.shade600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildHeader(),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Riwayat Kegiatan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF333333))),
              ),
              const SizedBox(height: 12),
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

  Widget _buildHeader() {
    return Obx(() {
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
        
        final currentTimestamp = data['createdAt'] as Timestamp?;
        if (currentTimestamp == null) return const SizedBox.shrink();
        
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

  Widget _buildActivityCard(Map<String, dynamic> data) {
    final timestamp = data['activityTimestamp'] as Timestamp? ?? data['createdAt'] as Timestamp?;
    final String timeString = timestamp != null
        ? DateFormat('HH:mm', 'id_ID').format(timestamp.toDate())
        : '--:--';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Get.dialog(_ActivityDetailDialog(data: data));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: CachedNetworkImage(
                  imageUrl: data['imageUrl'] ?? '',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 80, width: 80, color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 80, width: 80, color: Colors.red.shade50,
                    child: const Icon(Icons.broken_image, color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time_filled, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          timeString,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 28),
            ],
          ),
        ),
      ),
    );
  }

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

class _ActivityDetailDialog extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ActivityDetailDialog({required this.data});

  @override
  Widget build(BuildContext context) {
    final timestamp = data['activityTimestamp'] as Timestamp? ?? data['createdAt'] as Timestamp?;
    final String dateTimeString = timestamp != null
        ? DateFormat('EEEE, dd MMMM yyyy - HH:mm', 'id_ID').format(timestamp.toDate())
        : 'Waktu tidak tersedia';
    final imageUrl = data['imageUrl'] ?? '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // **PERUBAHAN: GAMBAR DIBUNGKUS DENGAN GestureDetector**
              GestureDetector(
                onTap: () {
                  // Navigasi ke halaman fullscreen saat gambar diketuk
                  if (imageUrl.isNotEmpty) {
                    Get.to(() => _FullScreenImageView(imageUrl: imageUrl), transition: Transition.fadeIn);
                  }
                },
                child: Hero( // Tambahkan Hero untuk animasi transisi yang mulus
                  tag: imageUrl,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      height: 250,
                      placeholder: (context, url) => Container(
                        height: 250,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 250,
                        color: Colors.red.shade50,
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                data['room'] ?? 'Ruangan Tidak Ditemukan',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              _buildDetailRow(
                icon: Icons.person_pin_rounded,
                label: 'Petugas',
                value: data['officerName'] ?? 'Tidak diketahui',
              ),
              const Divider(height: 20),
              _buildDetailRow(
                icon: Icons.business_rounded,
                label: 'Lantai',
                value: 'Lantai ${data['floor'] ?? '-'}',
              ),
              const Divider(height: 20),
              _buildDetailRow(
                icon: Icons.calendar_month_rounded,
                label: 'Waktu',
                value: dateTimeString,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tutup', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}


// **WIDGET BARU: HALAMAN UNTUK TAMPILAN GAMBAR FULLSCREEN**
class _FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImageView({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Tombol back akan otomatis ditambahkan oleh GetX / Navigator
      ),
      body: Hero( // Gunakan Hero dengan tag yang sama untuk animasi
        tag: imageUrl,
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(imageUrl),
          loadingBuilder: (context, event) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.error_outline, color: Colors.white, size: 50),
          ),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2.0,
        ),
      ),
    );
  }
}