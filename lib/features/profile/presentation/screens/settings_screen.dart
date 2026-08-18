import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_logout_dialog.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../providers/settings_provider.dart';
import '../../../animals/domain/animal_type.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'App Settings',
          style: AppTypography.displayHeadline.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(AppSpacing.horizontalPadding),
          child: ResponsiveBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Notifications
              _SettingsGroup(
                title: 'Notifications & Alerts',
                children: [
                  SwitchListTile(
                    activeTrackColor: AppColors.surface,
                    activeThumbColor: AppColors.primaryGold,
                    title: const Text('Due Date Reminders', style: AppTypography.inputText),
                    subtitle: const Text(
                      'Notify 14 days before expected foaling/whelping',
                      style: AppTypography.finePrint,
                    ),
                    value: settings.dueDateReminders,
                    onChanged: (val) => settingsNotifier.toggleDueDateReminders(val),
                  ),
                  SwitchListTile(
                    activeTrackColor: AppColors.surface,
                    activeThumbColor: AppColors.primaryGold,
                    title: const Text('Foaling & Whelping Alerts', style: AppTypography.inputText),
                    subtitle: const Text(
                      'Critical labor & nesting alerts',
                      style: AppTypography.finePrint,
                    ),
                    value: settings.foalingAlerts,
                    onChanged: (val) => settingsNotifier.toggleFoalingAlerts(val),
                  ),
                  SwitchListTile(
                    activeTrackColor: AppColors.surface,
                    activeThumbColor: AppColors.primaryGold,
                    title: const Text('Email Summary Reports', style: AppTypography.inputText),
                    subtitle: const Text(
                      'Weekly breeder digest to registered email',
                      style: AppTypography.finePrint,
                    ),
                    value: settings.emailNotifications,
                    onChanged: (val) => settingsNotifier.toggleEmailNotifications(val),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Section 2: Default Species Configuration
              _SettingsGroup(
                title: 'Default Species Configuration',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Primary Breeding Species', style: AppTypography.inputText),
                              const SizedBox(height: 2),
                              Text(
                                'Default predictor calculations: ${settings.defaultSpecies.displayName}',
                                style: AppTypography.finePrint,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<AnimalType>(
                          value: settings.defaultSpecies,
                          dropdownColor: AppColors.surface,
                          underline: const SizedBox.shrink(),
                          items: AnimalType.values.map((type) {
                            return DropdownMenuItem<AnimalType>(
                              value: type,
                              child: Text(
                                type.shortName,
                                style: const TextStyle(color: AppColors.primaryGold, fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) settingsNotifier.setDefaultSpecies(val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Section 3: App Information
              const _SettingsGroup(
                title: 'System Information',
                children: [
                  _SystemInfoTile(
                    label: 'Application Version',
                    value: '1.0.0 (Build 1)',
                  ),
                  _SystemInfoTile(
                    label: 'Supabase Backend Region',
                    value: 'US East (Production)',
                  ),
                  _SystemInfoTile(
                    label: 'Architecture',
                    value: 'Feature-First Riverpod',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Account Actions
              Center(
                child: Column(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.logout_rounded, color: AppColors.primaryGold),
                      label: const Text(
                        'Log Out of ABP Account',
                        style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        final confirmed = await AppLogoutDialog.show(context);
                        if (confirmed && context.mounted) {
                          await ref.read(authControllerProvider.notifier).signOut();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                      label: const Text(
                        'Delete Account & Erase All Data',
                        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/delete-account');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

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
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            child: Text(title, style: AppTypography.featureTitle),
          ),
          const Divider(color: AppColors.inputBorder, height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _SystemInfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _SystemInfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: AppTypography.inputText),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: AppTypography.finePrint,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
