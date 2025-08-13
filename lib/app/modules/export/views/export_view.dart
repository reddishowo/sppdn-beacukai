// lib/app/modules/export/views/export_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/export_controller.dart';

class ExportView extends GetView<ExportController> {
  const ExportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data Kegiatan'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.userList.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ditemukan pengguna dengan data kegiatan.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: controller.userList.length,
          itemBuilder: (context, index) {
            final user = controller.userList[index];
            final userId = user['uid'];
            final userName = user['name'];
            final userEmail = user['email'];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withAlpha(50),
                  foregroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.person),
                ),
                title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(userEmail),
                trailing: Obx(() {
                  // Show a loading indicator only for the user being exported
                  if (controller.isExporting.value == userId) {
                    return const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    );
                  }
                  return ElevatedButton.icon(
                    onPressed: () => controller.exportUserData(userId, userName),
                    icon: const Icon(Icons.download_for_offline, size: 20),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  );
                }),
              ),
            );
          },
        );
      }),
    );
  }
}