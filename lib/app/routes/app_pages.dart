import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';

// File: /sppdn/lib/app/routes/app_pages.dart (Versi Akhir yang Benar)

import '../modules/splash/views/splash_view.dart'; // <-- IMPOR SPLASH VIEW

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // 1. GANTI INITIAL ROUTE MENJADI SPLASH
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    // 2. TAMBAHKAN GETPAGE UNTUK SPLASH
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}
