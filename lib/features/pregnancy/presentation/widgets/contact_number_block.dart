import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../contacts/presentation/providers/contact_provider.dart';
import '../../../contacts/presentation/widgets/select_or_add_contact_modal.dart';
import '../../../contacts/domain/contact.dart';

class ContactNumberBlock extends ConsumerWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final TextEditingController? nameController;
  final VoidCallback onSave;
  final bool isSaved;
  final IconData icon;
  final String? contactRole; // 'vet', 'farrier', 'dentist'

  const ContactNumberBlock({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    this.nameController,
    required this.onSave,
    this.isSaved = false,
    this.icon = Icons.phone_outlined,
    this.contactRole,
  });

  Future<void> _makeCall(BuildContext context) async {
    final number = controller.text.trim();
    if (number.isEmpty) return;
    final uri = Uri.parse('tel:${number.replaceAll(RegExp(r'[^0-9+]'), '')}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          AppFeedbackSnackbar.showError(
            context,
            title: 'Call Unavailable',
            error: 'Cannot launch dialer for $number',
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        AppFeedbackSnackbar.showInfo(
          context,
          title: 'Dialing',
          message: 'Calling $number...',
        );
      }
    }
  }

  Future<void> _pickFromContacts(BuildContext context, WidgetRef ref) async {
    final contact = await SelectOrAddContactModal.show(
      context,
      title: 'Select $title Contact',
      defaultRole: contactRole,
    );
    if (contact != null) {
      if (contact.phone?.isNotEmpty == true) {
        controller.text = contact.phone!;
      }
      if (nameController != null) {
        nameController!.text = contact.name;
      }
      onSave();
    }
  }

  Future<void> _handleSaveAndAddToDirectory(BuildContext context, WidgetRef ref) async {
    onSave();
    final number = controller.text.trim();
    final name = nameController?.text.trim();

    if (number.isNotEmpty && contactRole != null) {
      try {
        final repo = ref.read(contactRepositoryProvider);
        final newContact = Contact(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          accountId: '',
          name: name?.isNotEmpty == true ? name! : '$title ($number)',
          phone: number,
          role: contactRole!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repo.saveContact(newContact);
        ref.invalidate(contactsListProvider(null));
        ref.invalidate(contactsListProvider(contactRole));
      } catch (e) {
        debugPrint('Auto-add to directory error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.displayHeadline.copyWith(fontSize: 16),
                  softWrap: true,
                ),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () => _pickFromContacts(context, ref),
                icon: const Icon(Icons.contacts_outlined, size: 16, color: AppColors.primaryGold),
                label: const Text('Directory', style: TextStyle(color: AppColors.primaryGold, fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (nameController != null) ...[
            CustomTextField(
              label: '$title Name / Clinic (Optional)',
              hintText: 'e.g. Dr. Emily Hayes',
              controller: nameController!,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 10),
          ],

          CustomTextField(
            label: '$title Phone / Mobile (Optional)',
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
                  onPressed: () => _handleSaveAndAddToDirectory(context, ref),
                  icon: const Icon(Icons.save_outlined, size: 16),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Save Details'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.inputField,
                    foregroundColor: AppColors.primaryGold,
                    side: const BorderSide(color: AppColors.primaryGold),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (hasNumber) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makeCall(context),
                    icon: const Icon(Icons.call, size: 16),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Call Now'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
