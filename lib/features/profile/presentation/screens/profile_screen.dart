import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userProfile = authState.value;

    final name = userProfile?.fullName.isNotEmpty == true ? userProfile!.fullName : 'Breeder User';
    final email = userProfile?.email ?? 'breeder@example.com';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'User Profile',
          style: AppTypography.displayHeadline.copyWith(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        child: Column(
          children: [
            // User Avatar Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.primaryGold, width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: AppColors.primaryGold, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: AppTypography.displayHeadline.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(email, style: AppTypography.body.copyWith(color: AppColors.primaryGold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.inputField,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: const Text(
                      'Verified Supabase Breeder Session',
                      style: AppTypography.finePrint,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile Info List
            _ProfileInfoSection(
              title: 'Account & Credentials',
              items: [
                _InfoTile(icon: Icons.person_outline, label: 'Full Name', value: name),
                _InfoTile(icon: Icons.email_outlined, label: 'Email Address', value: email),
                _InfoTile(
                  icon: Icons.security_outlined,
                  label: 'Password & Security',
                  value: '••••••••',
                  onTap: () {
                    Navigator.pushNamed(context, '/update-password');
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sign Out CTA
            GradientCtaButton(
              text: 'Sign Out & Terminate Session',
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
                }
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _ProfileInfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: AppTypography.featureTitle),
          ),
          const Divider(color: AppColors.inputBorder, height: 1),
          ...items,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGold, size: 20),
      title: Text(label, style: AppTypography.finePrint),
      subtitle: Text(value, style: AppTypography.inputText),
      trailing: onTap != null ? const Icon(Icons.chevron_right, color: AppColors.textMuted) : null,
      onTap: onTap,
    );
  }
}
