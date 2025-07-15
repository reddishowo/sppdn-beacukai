// lib/app/modules/profile/views/profile_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sppdn/app/routes/app_pages.dart';
import '../../auth/controllers/auth_controller.dart'; 
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _buildUserInfoCard(),
          const SizedBox(height: 24),
          _buildActionsMenu(context),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.blue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
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

  // **PERUBAHAN: Menu 'Edit Profil' dihapus**
  Widget _buildActionsMenu(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: GetBuilder<AuthController>(
        builder: (authController) {
          return Column(
            children: [
              // **Menu 'Edit Profil' telah dihapus dari sini**

              // Menu ini hanya tampil jika user adalah admin
              if (authController.isAdmin) ...[
                _buildProfileMenuItem(
                  icon: Icons.room_preferences_rounded,
                  text: 'Kelola Ruangan',
                  onTap: () {
                    Get.toNamed(Routes.MANAGE_ROOMS);
                  },
                ),
                // Divider ini hanya muncul jika menu 'Kelola Ruangan' ada
                const Divider(height: 1, indent: 16, endIndent: 16),
              ],
              
              // Menu Sign Out selalu ada
              _buildProfileMenuItem(
                icon: Icons.logout,
                text: 'Sign Out',
                textColor: Colors.red,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }

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
              Get.back();
              controller.signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // **PERUBAHAN: Fungsi _showEditProfileDialog telah dihapus sepenuhnya**
}