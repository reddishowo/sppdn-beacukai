import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class RegisterController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  RxBool isPasswordHidden = true.obs;
  RxBool isConfirmPasswordHidden = true.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }
  
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }
  
  void register() {
    if (formKey.currentState!.validate()) {
      AuthController.instance.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    }
  }
  
  void registerWithGoogle() {
    AuthController.instance.signInWithGoogle();
  }
  
  void goToLogin() {
    Get.back();
  }
}