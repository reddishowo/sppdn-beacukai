// File: /sppdn/lib/app/modules/home/views/home_tab.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Welcome Banner
          _buildWelcomeBanner(),
          const SizedBox(height: 24),

          // Konten lainnya bisa ditambahkan di sini
          const Center(
            child: Text(
              'Konten Halaman Utama',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.home_work_outlined, size: 100, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Halo,',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          Obx(
            () => Text(
              controller.displayName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}