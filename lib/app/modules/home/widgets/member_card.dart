import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_management_app/app/data/models/member_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_colors.dart';
import 'package:gym_management_app/app/modules/home/controllers/home_controller.dart';
import 'package:gym_management_app/app/data/services/member_service.dart';

class MemberCard extends StatelessWidget {
  final Member member;
  final bool isExpiring;
  final VoidCallback? onTap;

  const MemberCard({
    super.key,
    required this.member,
    this.isExpiring = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntilExpiry = member.planEndDate
        .difference(DateTime.now())
        .inDays;
    final isActive = DateTime.now().isBefore(member.planEndDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ).copyWith(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          FontAwesomeIcons.user,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${member.memberName} ${member.memberLastname}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(FontAwesomeIcons.creditCard, size: 12),
                                const SizedBox(width: 3),
                                Text(
                                  'Card: ${member.cardNumber}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.locationDot,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      member.address,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 6),
                                Container(width: 1, height: 12),
                                const SizedBox(width: 6),
                                Row(
                                  children: [
                                    Icon(FontAwesomeIcons.phone, size: 12),
                                    const SizedBox(width: 3),
                                    Text(
                                      member.phoneNumber,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          onDelete(context);
                        },
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(30, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(FontAwesomeIcons.xmark, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusChip(isActive, daysUntilExpiry),
                      const SizedBox(width: 6),
                      if (isActive && daysUntilExpiry <= 7) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$daysUntilExpiry day${daysUntilExpiry == 1 ? '' : 's'} remaining',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      if (!isActive) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Expired ${-daysUntilExpiry} day${-daysUntilExpiry == 1 ? '' : 's'} ago',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildPlanRow(
                    'Plan Start',
                    DateFormat('MMM dd, yyyy').format(member.planStartDate),
                    FontAwesomeIcons.calendarCheck,
                  ),
                  const SizedBox(height: 6),
                  _buildPlanRow(
                    'Plan End',
                    DateFormat('MMM dd, yyyy').format(member.planEndDate),
                    FontAwesomeIcons.calendarDay,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final sanitized = member.phoneNumber.replaceAll(
                        RegExp(r'[^0-9+]'),
                        '',
                      );
                      final uri = Uri.parse('https://wa.me/+91$sanitized');
                      final ok = await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                      if (!ok) {
                        Get.snackbar(
                          'Error',
                          'Could not open WhatsApp',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade900,
                        );
                      }
                    },
                    icon: const Icon(
                      FontAwesomeIcons.whatsapp,
                      color: AppColors.primary,
                      size: 14,
                    ),
                    label: Text(
                      'WhatsApp',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(
                        color: AppColors.divider,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      final uri = Uri(scheme: 'tel', path: member.phoneNumber);
                      final ok = await launchUrl(uri);
                      if (!ok && context.mounted) {
                        Get.snackbar(
                          'Error',
                          'Could not launch dialer',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade900,
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(12),
                        ),
                        side: BorderSide(color: AppColors.divider, width: 1.5),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(FontAwesomeIcons.phone, size: 14),
                    label: const Text('Call', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive, int daysUntilExpiry) {
    Color chipColor;
    String chipText;
    IconData chipIcon;

    if (!isActive) {
      chipColor = Colors.red;
      chipText = 'Expired';
      chipIcon = FontAwesomeIcons.hourglassEnd;
    } else if (daysUntilExpiry <= 7) {
      chipColor = Colors.orange;
      chipText = 'Expiring';
      chipIcon = FontAwesomeIcons.triangleExclamation;
    } else {
      chipColor = Colors.green;
      chipText = 'Active';
      chipIcon = FontAwesomeIcons.check;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 12, color: chipColor),
          const SizedBox(width: 3),
          Text(
            chipText,
            style: TextStyle(
              fontSize: 11,
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Future<void> onDelete(BuildContext context) async {
    final confirmed = await _confirmDelete(context);
    if (confirmed != true) return;
    final controller = Get.find<HomeController>();
    final service = MemberService();
    try {
      await service.deleteMember(member.id);
      controller.deleteMemberLocally(member.id);
      Get.snackbar(
        'Deleted',
        'Member removed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete member: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Member'),
          content: const Text(
            'Are you sure you want to delete this member? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
