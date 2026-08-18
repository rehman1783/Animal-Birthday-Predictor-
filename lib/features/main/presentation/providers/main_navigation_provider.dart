import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainNavigationState {
  final int selectedIndex;
  final String? initialCategory; // e.g. 'foals', 'puppies', 'kittens'
  final String? initialSpeciesTab; // e.g. 'horse', 'dog', 'cat'
  final String? damId;

  const MainNavigationState({
    this.selectedIndex = 0,
    this.initialCategory,
    this.initialSpeciesTab,
    this.damId,
  });

  MainNavigationState copyWith({
    int? selectedIndex,
    String? initialCategory,
    String? initialSpeciesTab,
    String? damId,
  }) {
    return MainNavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      initialCategory: initialCategory ?? this.initialCategory,
      initialSpeciesTab: initialSpeciesTab ?? this.initialSpeciesTab,
      damId: damId ?? this.damId,
    );
  }
}

class MainNavigationNotifier extends StateNotifier<MainNavigationState> {
  MainNavigationNotifier([int initialIndex = 0, String? initialCategory])
      : super(MainNavigationState(
          selectedIndex: initialIndex,
          initialCategory: initialCategory,
        ));

  void setTab(int index, {String? category, String? speciesTab, String? damId}) {
    state = MainNavigationState(
      selectedIndex: index,
      initialCategory: category,
      initialSpeciesTab: speciesTab,
      damId: damId,
    );
  }
}

final mainNavigationProvider =
    StateNotifierProvider<MainNavigationNotifier, MainNavigationState>((ref) {
  return MainNavigationNotifier();
});
