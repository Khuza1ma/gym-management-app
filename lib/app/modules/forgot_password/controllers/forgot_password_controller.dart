import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_management_app/app/core/utils/validators.dart';
import 'package:gym_management_app/app/data/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  final RxBool isLoading = false.obs;
  String? validateEmail(String? value) => Validators.validateEmail(value);

  Future<void> sendResetEmail() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      await _authService.sendPasswordReset(email: emailController.text.trim());
      Get.back();
      Get.snackbar(
        'Email Sent',
        'A password reset link has been sent to your email.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
