// File: /sppdn/lib/app/modules/login/views/login_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  
  @override
  Widget build(BuildContext context) {
    // The background color is defined by the theme
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            // The Card's style is defined by the theme
            child: Card(
              elevation: 8.0, // Can keep a higher elevation for emphasis
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_open_rounded,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        'Sign in to your account',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        // Style comes from InputDecorationTheme
                        decoration: _inputDecoration(context, 'Email', 'Enter your email', Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your email';
                          if (!GetUtils.isEmail(value)) return 'Please enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Obx(() => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.isPasswordHidden.value,
                        decoration: _inputDecoration(context, 'Password', 'Enter your password', Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your password';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      )),
                      const SizedBox(height: 24),
                      
                      Obx(() => ElevatedButton(
                        // Style comes from ElevatedButtonTheme
                        onPressed: AuthController.instance.isLoading.value ? null : controller.login,
                        child: AuthController.instance.isLoading.value
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 3), // Color is inherited
                              )
                            : const Text('Login'),
                      )),
                      const SizedBox(height: 16),
                      
                      _buildDivider(),
                      const SizedBox(height: 16),
                      
                      Obx(() => OutlinedButton.icon(
                        // Style comes from OutlinedButtonTheme
                        onPressed: AuthController.instance.isLoading.value ? null : controller.loginWithGoogle,
                        icon: Image.asset('assets/google_logo.png', height: 20, width: 20),
                        label: const Text('Continue with Google'),
                      )),
                      const SizedBox(height: 24),
                      
                      _buildFooterLink("Don't have an account? ", "Register", controller.goToRegister),
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

  InputDecoration _inputDecoration(BuildContext context, String label, String hint, IconData icon) {
    // The base decoration comes from the theme, we just add specific details
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildFooterLink(String text1, String text2, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text1, style: const TextStyle(color: Colors.black54)), // This will be hard to see in dark mode, let's fix
        GestureDetector(
          onTap: onTap,
          child: Text(
            text2,
            style: TextStyle(
              color: Theme.of(Get.context!).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}