import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../dashboard/presentation/screens/dashboard_home_screen.dart';
import '../../../animals/presentation/screens/saved_animals_screen.dart';
import '../../../pregnancy/presentation/screens/pregnancy_module_screen.dart';
import '../../../foal/presentation/screens/foal_module_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../providers/main_navigation_provider.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final int? initialIndex;
  final String? initialFoalCategory;
  final String? initialSpeciesTab;

  const MainNavigationScreen({
    super.key,
    this.initialIndex,
    this.initialFoalCategory,
    this.initialSpeciesTab,
  });

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != null || widget.initialFoalCategory != null || widget.initialSpeciesTab != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(mainNavigationProvider.notifier).setTab(
                widget.initialIndex ?? 0,
                category: widget.initialFoalCategory,
                speciesTab: widget.initialSpeciesTab,
              );
        }
      });
    }
  }

  void _onTabTapped(int index) {
    ref.read(mainNavigationProvider.notifier).setTab(index);
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(mainNavigationProvider);
    final currentIndex = navState.selectedIndex;

    final List<Widget> screens = [
      DashboardHomeScreen(onNavigateTab: _onTabTapped),
      SavedAnimalsScreen(initialSpecies: navState.initialSpeciesTab),
      PregnancyModuleScreen(initialSpecies: navState.initialSpeciesTab),
      FoalModuleScreen(initialCategory: navState.initialCategory),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentIndex != 0) {
          ref.read(mainNavigationProvider.notifier).setTab(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          left: true,
          right: true,
          child: IndexedStack(
            index: currentIndex,
            children: screens,
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.inputBorder, width: 1.0),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: _onTabTapped,
            backgroundColor: AppColors.surface,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primaryGold,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: const [
              BottomNavigationBarViewItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarViewItem(
                icon: Icon(Icons.pets_outlined),
                activeIcon: Icon(Icons.pets),
                label: 'Animals',
              ),
              BottomNavigationBarViewItem(
                icon: Icon(Icons.monitor_heart_outlined),
                activeIcon: Icon(Icons.monitor_heart),
                label: 'Pregnancy',
              ),
              BottomNavigationBarViewItem(
                icon: Icon(Icons.child_care_outlined),
                activeIcon: Icon(Icons.child_care),
                label: 'Birth Log',
              ),
              BottomNavigationBarViewItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavigationBarViewItem extends BottomNavigationBarItem {
  const BottomNavigationBarViewItem({
    required super.icon,
    required super.activeIcon,
    required super.label,
  });
}
