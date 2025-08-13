// lib/app/modules/profile/views/profile_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sppdn/app/routes/app_pages.dart';
import 'package:sppdn/app/theme/theme_controller.dart'; // Import the theme controller
import '../../auth/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Find the ThemeController instance
    final ThemeController themeController = Get.find();

    return Scaffold(
      // The Scaffold color is now controlled by the theme
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _buildUserInfoCard(context),
          const SizedBox(height: 24),
          _buildActionsMenu(context, themeController), // Pass the controller to the menu
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    return Card(
      // The Card's style (color, shadow, etc.) comes from the CardTheme
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Obx(
          () => Column(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: Theme.of(context).primaryColor,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  child: Icon(Icons.person, size: 60, color: Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                controller.displayName,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                controller.userEmail,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context, ThemeController themeController) {
    return Card(
      child: GetBuilder<AuthController>(
        builder: (authController) {
          return Column(
            children: [
              // **NEW: MENU TO TOGGLE THEME**
              Obx(() => SwitchListTile(
                title: const Text('Dark Mode'),
                value: themeController.isDarkMode,
                onChanged: (value) => themeController.toggleTheme(),
                secondary: Icon(
                  themeController.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: Theme.of(context).primaryColor,
                ),
              )),
              
              if (authController.isAdmin)
                const Divider(height: 1, indent: 16, endIndent: 16),

              // Manage Rooms Menu
              // Manage Rooms & Export Menu for Admins
              if (authController.isAdmin) ...[
                _buildProfileMenuItem(
                  context: context,
                  icon: Icons.room_preferences_rounded,
                  text: 'Kelola Ruangan',
                  onTap: () {
                    Get.toNamed(Routes.MANAGE_ROOMS);
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16), // Optional separator
                // --- ADD THIS MENU ITEM ---
                _buildProfileMenuItem(
                  context: context,
                  icon: Icons.upload_file_rounded, // Choose a suitable icon
                  text: 'Export Data Kegiatan',
                  onTap: () {
                    Get.toNamed(Routes.EXPORT); // Navigate to the new screen
                  },
                ),
              ],
              
              const Divider(height: 1, indent: 16, endIndent: 16),
              
              // Sign Out Menu
              _buildProfileMenuItem(
                context: context,
                icon: Icons.logout,
                text: 'Sign Out',
                textColor: Colors.red.shade400,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final defaultTextColor = Theme.of(context).textTheme.bodyLarge?.color;
    return ListTile(
      leading: Icon(icon, color: textColor ?? defaultTextColor),
      title: Text(text, style: TextStyle(color: textColor ?? defaultTextColor, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        // The AlertDialog's style comes from the DialogTheme
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
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
}