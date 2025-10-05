import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/validators.dart';

class ChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final obscureCurrent = true.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  String? validateCurrent(String? value) {
    if (value == null || value.isEmpty) return 'Current password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateNew(String? value) {
    return Validators.validatePassword(value);
  }

  String? validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm new password';
    if (value != newPasswordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> changePassword() async {
    if (isLoading.value) return;
    final form = formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      Get.snackbar('Error', 'No authenticated user found');
      return;
    }

    isLoading.value = true;
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPasswordController.text);

      Get.back();
      Get.snackbar('Success', 'Password changed successfully');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Failed to change password');
    } catch (e) {
      Get.snackbar('Error', 'Failed to change password: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
