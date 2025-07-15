// lib/app/theme/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  // Set the theme based on the saved value, or use the system mode as default
  final Rx<ThemeMode> themeMode = (Get.isDarkMode ? ThemeMode.dark : ThemeMode.light).obs;

  @override
  void onInit() {
    super.onInit();
    // Load the saved theme on startup
    _loadThemeFromBox();
  }

  // Getter to easily check if dark mode is active
  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  // Load theme from GetStorage
  void _loadThemeFromBox() {
    // If there's no saved value, keep the system default.
    // The value can be null the first time the app is opened.
    bool isDarkModeSaved = _box.read(_key) ?? Get.isDarkMode;
    themeMode.value = isDarkModeSaved ? ThemeMode.dark : ThemeMode.light;
  }

  // Save theme to GetStorage
  Future<void> _saveThemeToBox(bool isDarkMode) async {
    await _box.write(_key, isDarkMode);
  }

  // Toggle the theme and save the new preference
  void toggleTheme() {
    themeMode.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _saveThemeToBox(isDarkMode);
    // update() informs GetBuilders to rebuild the UI
    update();
  }
}