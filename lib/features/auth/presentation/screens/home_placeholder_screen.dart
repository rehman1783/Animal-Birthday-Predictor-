import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../providers/auth_provider.dart';

class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final profile = authState.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'ABP Main Dashboard',
          style: TextStyle(color: AppColors.primaryGold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.primaryGold),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGold,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.primaryGold,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              profile?.fullName.isNotEmpty == true
                  ? 'Welcome, ${profile!.fullName}!'
                  : 'Welcome to ABP!',
              style: AppTypography.displayHeadline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (profile?.email.isNotEmpty == true)
              Text(
                profile!.email,
                style: AppTypography.body.copyWith(color: AppColors.primaryGold),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            const Text(
              'Authenticated via Supabase Auth.\nSession active & saved.',
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            GradientCtaButton(
              text: 'Sign Out & Return to Sign In',
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
