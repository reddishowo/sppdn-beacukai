// File: /sppdn/lib/app/modules/login/views/login_view.dart (Versi Diperbarui)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Latar belakang abu-abu lembut
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min, // Agar card pas dengan konten
                    children: [
                      // Logo or App Name
                      const Icon(
                        Icons.lock_open_rounded,
                        size: 60,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Selamat Datang Kembali!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      const Text(
                        'Masuk ke akun Anda',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Email Field
                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration('Email', 'Masukkan email Anda', Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan email Anda';
                          if (!GetUtils.isEmail(value)) return 'Masukkan email yang valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Password Field
                      Obx(() => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.isPasswordHidden.value,
                        decoration: _inputDecoration('Password', 'Masukkan password Anda', Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan password Anda';
                          if (value.length < 6) return 'Password minimal 6 karakter';
                          return null;
                        },
                      )),
                      const SizedBox(height: 24),
                      
                      // Login Button
                      Obx(() => ElevatedButton(
                        onPressed: AuthController.instance.isLoading.value ? null : controller.login,
                        style: _buttonStyle(),
                        child: AuthController.instance.isLoading.value
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : const Text('Login', style: TextStyle(fontSize: 16)),
                      )),
                      const SizedBox(height: 16),
                      
                      // Divider
                      _buildDivider(),
                      const SizedBox(height: 16),
                      
                      // Google Sign In Button
                      Obx(() => OutlinedButton.icon(
                        onPressed: AuthController.instance.isLoading.value ? null : controller.loginWithGoogle,
                        icon: Image.asset('assets/google_logo.png', height: 20, width: 20), // Ganti dengan logo google jika ada
                        label: const Text('Lanjutkan dengan Google'),
                        style: _buttonStyle(isOutlined: true),
                      )),
                      const SizedBox(height: 24),
                      
                      // Register Link
                      _buildFooterLink("Belum punya akun? ", "Daftar", controller.goToRegister),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper untuk membuat dekorasi input
  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  // Helper untuk membuat style tombol
  ButtonStyle _buttonStyle({bool isOutlined = false}) {
    return (isOutlined ? OutlinedButton.styleFrom(
      foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue),
    ) : ElevatedButton.styleFrom(
      backgroundColor: Colors.blue, foregroundColor: Colors.white,
    )).copyWith(
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 16)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );
  }

  // Helper untuk membuat divider
  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('ATAU', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  // Helper untuk membuat link footer
  Widget _buildFooterLink(String text1, String text2, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text1, style: const TextStyle(color: Colors.black54)),
        GestureDetector(
          onTap: onTap,
          child: Text(
            text2,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}