import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_pages.dart';
import '../../../controller/theme_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), elevation: 0),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildUserInfoCard(),
              const SizedBox(height: 20),
              _buildNavButtons(context),
              const SizedBox(height: 20),
              _buildTextField(
                controller: controller.displayNameController,
                label: 'Display Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: controller.emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: controller.phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 24),
              Obx(
                () => _buildPrimaryButton(
                  onPressed: controller.isUpdating.value
                      ? null
                      : controller.updateProfile,
                  child: controller.isUpdating.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surface,
                          ),
                        )
                      : const Text('Update Profile'),
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildOutlinedButton(
          onPressed: () => showLogoutDialog(context),
          child: Text(
            'Logout',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> showLogoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildOutlinedButton(
            onPressed: () => Get.toNamed(Routes.CHANGE_PASSWORD),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock_outline, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Change Password',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 50,
          child: PopupMenuButton<ThemeMode>(
            style: ButtonStyle(
              side: WidgetStateProperty.all(
                const BorderSide(color: AppColors.divider, width: 2),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            icon: Row(
              children: [
                const Icon(Icons.color_lens_outlined, color: AppColors.primary),
                const SizedBox(width: 4),
                Obx(() {
                  final mode = ThemeController.to.themeMode.value;
                  String text;
                  switch (mode) {
                    case ThemeMode.system:
                      text = 'System';
                      break;
                    case ThemeMode.light:
                      text = 'Light';
                      break;
                    case ThemeMode.dark:
                      text = 'Dark';
                      break;
                  }
                  return Text(
                    text,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
              ],
            ),
            onSelected: (mode) => ThemeController.to.setThemeMode(mode),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: const [
                    Icon(Icons.settings, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('System'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: const [
                    Icon(Icons.light_mode, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Light'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: const [
                    Icon(Icons.dark_mode, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Dark'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: _outlineInputBorder(),
          disabledBorder: _outlineInputBorder(),
          enabledBorder: _outlineInputBorder(),
          filled: true,
          fillColor: Theme.of(Get.context!).cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _outlineInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.divider, width: 1),
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

  Widget _buildOutlinedButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.divider, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        fixedSize: Size(double.infinity, 50),
      ),
      child: child,
    );
  }

  Widget _buildUserInfoCard() {
    return Obx(() {
      final user = controller.currentUser.value;
      if (user == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(user.email, style: const TextStyle(fontSize: 14)),
            if (user.role != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.role!.toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
