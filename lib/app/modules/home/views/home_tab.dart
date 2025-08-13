// lib/app/modules/home/views/home_tab.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import '../controllers/home_controller.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          color: Theme.of(context).primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildHeader(context),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Riwayat Kegiatan',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
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
                      return _buildErrorState(
                          context, 'An error occurred: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    final docs = snapshot.data!.docs;
                    return _buildGroupedListView(context, docs);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Obx(() {
      final String displayName = controller.displayName;
      final String initials = displayName.isNotEmpty
          ? displayName
              .trim()
              .split(' ')
              .map((l) => l[0])
              .take(2)
              .join()
              .toUpperCase()
          : 'U';

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo, Selamat Datang!',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Theme.of(context).hintColor)),
              const SizedBox(height: 2),
              Text(displayName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          CircleAvatar(
            radius: 26,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
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
      return 'Today';
    } else if (DateTime(date.year, date.month, date.day) == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    }
  }

  bool _isSameDay(Timestamp? a, Timestamp b) {
    if (a == null) return false;
    final dateA = a.toDate();
    final dateB = b.toDate();
    return dateA.year == dateB.year &&
        dateA.month == dateB.month &&
        dateA.day == dateB.day;
  }

  Widget _buildGroupedListView(
      BuildContext context, List<QueryDocumentSnapshot> docs) {
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
                padding:
                    const EdgeInsets.only(top: 20.0, bottom: 12.0, left: 4.0),
                child: Text(
                  _getFormattedDateHeader(currentTimestamp),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).hintColor),
                ),
              ),
            _buildActivityCard(context, data),
          ],
        );
      },
    );
  }

  Widget _buildActivityCard(BuildContext context, Map<String, dynamic> data) {
    final timestamp =
        data['activityTimestamp'] as Timestamp? ?? data['createdAt'] as Timestamp?;
    final String timeString = timestamp != null
        ? DateFormat('HH:mm', 'id_ID').format(timestamp.toDate())
        : '--:--';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                    height: 80,
                    width: 80,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child:
                        Icon(Icons.image, color: Theme.of(context).hintColor),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 80,
                    width: 80,
                    color: Colors.red.withOpacity(0.1),
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
                      data['room'] ?? 'Unspecified Room',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 14, color: Theme.of(context).hintColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            data['officerName'] ?? 'Unknown Officer',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Theme.of(context).hintColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time_filled,
                            size: 14, color: Theme.of(context).hintColor),
                        const SizedBox(width: 6),
                        Text(
                          timeString,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Theme.of(context).hintColor.withOpacity(0.5),
                  size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded,
              size: 80, color: Theme.of(context).hintColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No activities yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).hintColor)),
          const SizedBox(height: 8),
          Text('Press the + button to add a new activity.',
              style:
                  TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          const Text('Oops! Something Went Wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(message,
                style: TextStyle(
                    fontSize: 14, color: Theme.of(context).hintColor),
                textAlign: TextAlign.center),
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
    final timestamp =
        data['activityTimestamp'] as Timestamp? ?? data['createdAt'] as Timestamp?;
    final String dateTimeString = timestamp != null
        ? DateFormat('EEEE, dd MMMM yyyy - HH:mm', 'id_ID')
            .format(timestamp.toDate())
        : 'Time not available';
    final imageUrl = data['imageUrl'] ?? '';

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  if (imageUrl.isNotEmpty) {
                    Get.to(() => _FullScreenImageView(imageUrl: imageUrl),
                        transition: Transition.fadeIn);
                  }
                },
                child: Hero(
                  tag: imageUrl,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      height: 250,
                      placeholder: (context, url) => Container(
                        height: 250,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 250,
                        color: Colors.red.withOpacity(0.1),
                        child:
                            const Icon(Icons.broken_image, size: 50, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                data['room'] ?? 'Room Not Found',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                context,
                icon: Icons.person_pin_rounded,
                label: 'Petugas',
                value: data['officerName'] ?? 'Unknown',
              ),
              const Divider(height: 20),
              _buildDetailRow(
                context,
                icon: Icons.business_rounded,
                label: 'Lantai',
                value: 'Lantai ${data['floor'] ?? '-'}',
              ),
              const Divider(height: 20),
              _buildDetailRow(
                context,
                icon: Icons.calendar_month_rounded,
                label: 'Waktu',
                value: dateTimeString,
              ),
              // --- DISPLAY KETERANGAN IF IT EXISTS ---
              if (data.containsKey('keterangan') &&
                  (data['keterangan'] as String).isNotEmpty) ...[
                const Divider(height: 20),
                _buildDetailRow(
                  context,
                  icon: Icons.notes_rounded,
                  label: 'Keterangan',
                  value: data['keterangan'] ?? 'Tidak ada keterangan.',
                ),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Tutup', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      TextStyle(color: Theme.of(context).hintColor, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  const _FullScreenImageView({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(imageUrl),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
        ),
      ),
    );
  }
}