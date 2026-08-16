import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/custom_text_field.dart';

class ContactNumberBlock extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final VoidCallback onSave;
  final bool isSaved;
  final IconData icon;

  const ContactNumberBlock({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.onSave,
    this.isSaved = false,
    this.icon = Icons.phone_outlined,
  });

  Future<void> _makeCall(BuildContext context) async {
    final number = controller.text.trim();
    if (number.isEmpty) return;
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot launch dialer for $number')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Calling $number...')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasNumber = controller.text.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.surface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.displayHeadline.copyWith(fontSize: 16),
              ),
              const Spacer(),
              if (!hasNumber)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.inputField,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'No Number Added',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          CustomTextField(
            label: '$title Number',
            hintText: hintText,
            controller: controller,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save_outlined, size: 16),
                  label: const Text('Save Number'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.inputField,
                    foregroundColor: AppColors.primaryGold,
                    side: const BorderSide(color: AppColors.primaryGold),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (hasNumber) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makeCall(context),
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text('Call Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
