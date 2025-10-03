import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_management_app/app/data/models/member_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_colors.dart';

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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      FontAwesomeIcons.user,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${member.memberName} ${member.memberLastname}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.creditCard,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Card: ${member.cardNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.phone,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              member.phoneNumber,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(isActive, daysUntilExpiry),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isActive && daysUntilExpiry <= 7) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$daysUntilExpiry day${daysUntilExpiry == 1 ? '' : 's'} remaining',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    if (!isActive) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Expired ${-daysUntilExpiry} day${-daysUntilExpiry == 1 ? '' : 's'} ago',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildPlanRow(
                      'Plan Start',
                      DateFormat('MMM dd, yyyy').format(member.planStartDate),
                      FontAwesomeIcons.calendarCheck,
                    ),
                    const SizedBox(height: 8),
                    _buildPlanRow(
                      'Plan End',
                      DateFormat('MMM dd, yyyy').format(member.planEndDate),
                      FontAwesomeIcons.calendarDay,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final sanitized = member.phoneNumber.replaceAll(
                                RegExp(r'[^0-9+]'),
                                '',
                              );
                              final uri = Uri.parse(
                                'https://wa.me/+91$sanitized',
                              );
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
                            ),
                            label: Text(
                              'WhatsApp',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(
                                color: AppColors.divider,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              final uri = Uri(
                                scheme: 'tel',
                                path: member.phoneNumber,
                              );
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(FontAwesomeIcons.phone),
                            label: const Text('Call'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            chipText,
            style: TextStyle(
              fontSize: 12,
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
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
