// lib/app/modules/register/views/register_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The background is now handled by the theme
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
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
                        Icons.person_add_alt_1_rounded,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        'Create New Account',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        'Start your journey with us',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).hintColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      TextFormField(
                        controller: controller.nameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(context, 'Full Name', 'Enter your full name', Icons.person_outline),
                        validator: (value) => value == null || value.isEmpty ? 'Please enter your full name' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
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
                        decoration: _inputDecoration(context, 'Password', 'Create your password', Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility,
                              color: Theme.of(context).hintColor,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please create a password';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      )),
                      const SizedBox(height: 16),
                      
                      Obx(() => TextFormField(
                        controller: controller.confirmPasswordController,
                        obscureText: controller.isConfirmPasswordHidden.value,
                        decoration: _inputDecoration(context, 'Confirm Password', 'Repeat your password', Icons.lock_outline_rounded).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isConfirmPasswordHidden.value ? Icons.visibility_off : Icons.visibility,
                              color: Theme.of(context).hintColor,
                            ),
                            onPressed: controller.toggleConfirmPasswordVisibility,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please confirm your password';
                          if (value != controller.passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      )),
                      const SizedBox(height: 24),
                      
                      Obx(() => ElevatedButton(
                        onPressed: AuthController.instance.isLoading.value ? null : controller.register,
                        child: AuthController.instance.isLoading.value
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              )
                            : const Text('Register'),
                      )),
                      const SizedBox(height: 16),
                      
                      _buildDivider(context),
                      const SizedBox(height: 16),
                      
                      Obx(() => OutlinedButton.icon(
                        onPressed: AuthController.instance.isLoading.value ? null : controller.registerWithGoogle,
                        icon: Image.asset('assets/google_logo.png', height: 20, width: 20),
                        label: const Text('Continue with Google'),
                      )),
                      const SizedBox(height: 24),
                      
                      _buildFooterLink(context, "Already have an account? ", "Login", controller.goToLogin),
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
    // This now simply applies labels to the globally themed InputDecoration
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Theme.of(context).hintColor),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: TextStyle(color: Theme.of(context).hintColor)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String text1, String text2, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text1, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        GestureDetector(
          onTap: onTap,
          child: Text(
            text2,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}