import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:gym_management_app/app/data/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final AuthService _authService = AuthService();
  final isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    displayNameController.text = 'User';
    emailController.text = 'user@example.com';
  }

  Future<void> updateProfile() async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      Get.snackbar('Profile', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> launchPhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(uri)) {
      Get.snackbar('Error', 'Could not launch phone dialer');
    }
  }

  Future<void> launchWhatsApp(String phoneNumber) async {
    final sanitized = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('https://wa.me/$sanitized');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Could not open WhatsApp');
    }
  }
}
