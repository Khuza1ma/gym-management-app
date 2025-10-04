import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_management_app/app/data/models/member_model.dart';
import '../../../data/services/member_service.dart';

class AddMemberController extends GetxController {
  final MemberService _memberService = MemberService();

  final formKey = GlobalKey<FormState>();
  final memberNameController = TextEditingController();
  final memberLastnameController = TextEditingController();
  final cardNumberController = TextEditingController();
  final phoneNumberController = TextEditingController();

  final isLoading = false.obs;
  final Rx<DateTime?> planStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> planEndDate = Rx<DateTime?>(null);

  final RxBool isEditing = false.obs;
  Member? memberToEdit;

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      if (arguments['isEditing'] == true && arguments['member'] is Member) {
        isEditing.value = true;
        memberToEdit = arguments['member'];
        _populateFormForEditing();
      }
    }

    if (!isEditing.value) {
      planStartDate.value = DateTime.now();
      planEndDate.value = DateTime.now().add(const Duration(days: 30));
    }
  }

  void _populateFormForEditing() {
    if (memberToEdit != null) {
      memberNameController.text = memberToEdit!.memberName;
      memberLastnameController.text = memberToEdit!.memberLastname;
      cardNumberController.text = memberToEdit!.cardNumber.toString();
      phoneNumberController.text = memberToEdit!.phoneNumber;
      planStartDate.value = memberToEdit!.planStartDate;
      planEndDate.value = memberToEdit!.planEndDate;
    }
  }

  @override
  void onClose() {
    memberNameController.dispose();
    memberLastnameController.dispose();
    cardNumberController.dispose();
    phoneNumberController.dispose();
    super.onClose();
  }

  Future<void> selectPlanStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: planStartDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      planStartDate.value = picked;
      if (planEndDate.value != null && picked.isAfter(planEndDate.value!)) {
        planEndDate.value = picked.add(const Duration(days: 30));
      }
    }
  }

  Future<void> selectPlanEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          planEndDate.value ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: planStartDate.value ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      planEndDate.value = picked;
    }
  }

  Future<void> addMember() async {
    if (!formKey.currentState!.validate()) return;

    if (planStartDate.value == null || planEndDate.value == null) {
      Get.snackbar(
        'Error',
        'Please select both plan start and end dates',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      if (isEditing.value && memberToEdit != null) {
        final updatedMember = memberToEdit!.copyWith(
          memberName: memberNameController.text.trim(),
          memberLastname: memberLastnameController.text.trim(),
          cardNumber: int.tryParse(cardNumberController.text.trim()),
          phoneNumber: phoneNumberController.text.trim(),
          planStartDate: planStartDate.value!,
          planEndDate: planEndDate.value!,
          updatedAt: DateTime.now(),
        );

        await _memberService.updateMember(updatedMember);

        Get.back(result: updatedMember);
        Get.snackbar(
          'Success',
          'Member updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return;
      } else {
        final memberId = await _memberService.addMember(
          memberName: memberNameController.text.trim(),
          memberLastname: memberLastnameController.text.trim(),
          cardNumber: int.tryParse(cardNumberController.text.trim()) ?? 0,
          phoneNumber: phoneNumberController.text.trim(),
          planStartDate: planStartDate.value!,
          planEndDate: planEndDate.value!,
        );

        final newMember = Member(
          id: memberId,
          memberName: memberNameController.text.trim(),
          memberLastname: memberLastnameController.text.trim(),
          cardNumber: int.tryParse(cardNumberController.text.trim()) ?? 0,
          phoneNumber: phoneNumberController.text.trim(),
          planStartDate: planStartDate.value!,
          planEndDate: planEndDate.value!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        clearForm();
        Get.back(result: newMember);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to ${isEditing.value ? 'update' : 'add'} member: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    memberNameController.clear();
    memberLastnameController.clear();
    cardNumberController.clear();
    phoneNumberController.clear();
    planStartDate.value = DateTime.now();
    planEndDate.value = DateTime.now().add(const Duration(days: 30));
  }
}
