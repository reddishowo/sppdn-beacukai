// File 1: /lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sppdn/app/theme/app_theme.dart';
import 'package:sppdn/app/theme/theme_controller.dart';
import 'firebase_options.dart';
import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/routes/app_pages.dart';

void main() async {
  // Ensure bindings are ready before async operations
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize GetStorage for data persistence
  await GetStorage.init();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);
  // Run the application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Inject the ThemeController globally
    Get.put(ThemeController());

    // Use GetBuilder to rebuild MaterialApp when the theme changes
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return GetMaterialApp(
          title: "SPPDN",
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: controller.themeMode.value,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          initialBinding: BindingsBuilder(() {
            Get.put(AuthController(), permanent: true);
          }),
        );
      },
    );
  }
}