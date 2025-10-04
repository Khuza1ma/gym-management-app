import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:gym_management_app/app/data/services/auth_service.dart';
import 'package:gym_management_app/app/data/services/user_service.dart';
import 'package:gym_management_app/app/data/models/user_models.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  final isUpdating = false.obs;
  final isLoading = true.obs;
  final currentUser = Rxn<AppUser>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final user = await _userService.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
        displayNameController.text = user.displayName ?? '';
        emailController.text = user.email;
        phoneController.text = user.phoneNumber ?? '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (isUpdating.value || currentUser.value == null) return;
    
    isUpdating.value = true;
    try {
      final updatedUser = currentUser.value!.copyWith(
        displayName: displayNameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
      );
      
      // Update Firebase Auth display name
      await _userService.updateFirebaseDisplayName(updatedUser.displayName ?? '');
      
      // Update Firestore user data
      await _userService.updateUserProfile(updatedUser);
      
      // Update local user data
      currentUser.value = updatedUser;
      
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
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

  @override
  void onClose() {
    displayNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
