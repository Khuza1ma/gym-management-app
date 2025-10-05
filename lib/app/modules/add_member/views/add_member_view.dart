import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../controllers/add_member_controller.dart';

class AddMemberView extends GetView<AddMemberController> {
  const AddMemberView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isEditing.value ? 'Edit Member' : 'Add New Member',
            style: const TextStyle(
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.surface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildTextField(
                controller: controller.memberNameController,
                label: 'First Name',
                icon: FontAwesomeIcons.user,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: controller.memberLastnameController,
                label: 'Last Name',
                icon: FontAwesomeIcons.user,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: controller.cardNumberController,
                label: 'Card Number',
                icon: FontAwesomeIcons.idCard,
                keyboardType: TextInputType.number,
                validator: Validators.validateCardNumber,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: controller.phoneNumberController,
                label: 'Phone Number',
                isPhoneNumber: true,
                icon: FontAwesomeIcons.phone,
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhoneNumber,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: controller.addressController,
                label: 'Address',
                icon: FontAwesomeIcons.locationDot,
                validator: Validators.validateAddress,
                keyboardType: TextInputType.streetAddress,
              ),
              const SizedBox(height: 20),
              _buildDateField(
                label: 'Plan Start Date',
                icon: FontAwesomeIcons.calendar,
                dateObservable: controller.planStartDate,
                onTap: () => controller.selectPlanStartDate(context),
              ),
              const SizedBox(height: 20),
              _buildDateField(
                label: 'Plan End Date',
                icon: FontAwesomeIcons.calendarDays,
                dateObservable: controller.planEndDate,
                onTap: () => controller.selectPlanEndDate(context),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Obx(() => _buildSubmitButton()),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPhoneNumber = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          prefixText: isPhoneNumber ? '+91 ' : null,
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: outlineInputBorder(),
          disabledBorder: outlineInputBorder(),
          enabledBorder: outlineInputBorder(),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  OutlineInputBorder outlineInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.divider, width: 1),
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required Rx<DateTime?> dateObservable,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateObservable.value != null
                            ? DateFormat(
                                'MMM dd, yyyy',
                              ).format(dateObservable.value!)
                            : 'Select date',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const FaIcon(
                  FontAwesomeIcons.angleDown,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: controller.isLoading.value ? null : controller.addMember,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        fixedSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: controller.isLoading.value
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Obx(
              () => Text(
                controller.isEditing.value ? 'Update Member' : 'Add Member',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}
