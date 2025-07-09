import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Latar belakang yang konsisten dengan halaman lain
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87, // Agar judul terlihat di background terang
      ),
      // Gunakan ListView agar bisa di-scroll di layar kecil
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // Kartu Informasi Pengguna
          _buildUserInfoCard(),
          const SizedBox(height: 24),

          // Kartu Menu Aksi
          _buildActionsMenu(context),
        ],
      ),
    );
  }

  // Widget untuk kartu informasi pengguna
  Widget _buildUserInfoCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.blue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        // Gunakan Obx agar nama dan email selalu update
        child: Obx(
          () => Column(
            children: [
              const CircleAvatar(
                radius: 52,
                backgroundColor: Colors.blue,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                controller.displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                controller.userEmail,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menu aksi
  Widget _buildActionsMenu(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildProfileMenuItem(
            icon: Icons.edit_outlined,
            text: 'Edit Profil',
            onTap: () {
              Get.snackbar('Fitur Mendatang', 'Fitur edit profil akan segera hadir!');
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildProfileMenuItem(
            icon: Icons.settings_outlined,
            text: 'Pengaturan',
            onTap: () {
              Get.snackbar('Fitur Mendatang', 'Halaman pengaturan akan segera hadir!');
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildProfileMenuItem(
            icon: Icons.logout,
            text: 'Sign Out',
            textColor: Colors.red, // Warna khusus untuk aksi destruktif
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk membuat satu item menu
  Widget _buildProfileMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color textColor = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  // Dialog konfirmasi logout (tetap sama)
  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Tutup dialog
              controller.signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}