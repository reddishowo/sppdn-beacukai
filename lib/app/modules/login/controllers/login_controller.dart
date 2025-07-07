import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  RxBool isPasswordHidden = true.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }
  
  void login() {
    if (formKey.currentState!.validate()) {
      AuthController.instance.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    }
  }
  
  void loginWithGoogle() {
    AuthController.instance.signInWithGoogle();
  }
  
  void goToRegister() {
    Get.toNamed('/register');
  }
}