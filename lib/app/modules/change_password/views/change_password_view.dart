import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:gym_management_app/app/core/theme/app_colors.dart';

import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: Get.height * 0.15),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildFormCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Icon(FontAwesomeIcons.lock, size: 44, color: AppColors.primary),
        SizedBox(height: 12),
        Text(
          'Update your password',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6),
        Text(
          'Enter your current password and choose a new one.',
          style: TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(
              () => _passwordField(
                controller: controller.currentPasswordController,
                label: 'Current Password',
                icon: FontAwesomeIcons.lockOpen,
                validator: controller.validateCurrent,
                obscure: controller.obscureCurrent.value,
                onToggle: () => controller.obscureCurrent.toggle(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => _passwordField(
                controller: controller.newPasswordController,
                label: 'New Password',
                icon: FontAwesomeIcons.key,
                validator: controller.validateNew,
                obscure: controller.obscureNew.value,
                onToggle: () => controller.obscureNew.toggle(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => _passwordField(
                controller: controller.confirmPasswordController,
                label: 'Confirm New Password',
                icon: FontAwesomeIcons.check,
                validator: controller.validateConfirm,
                obscure: controller.obscureConfirm.value,
                onToggle: () => controller.obscureConfirm.toggle(),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => _buildPrimaryButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.changePassword,
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Theme.of(Get.context!).cardColor,
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _focusedBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.divider, width: 1),
    );
  }

  OutlineInputBorder _focusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        fixedSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: child,
    );
  }
}
