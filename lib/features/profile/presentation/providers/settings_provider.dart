import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../animals/domain/animal_type.dart';

class AppSettings {
  final bool dueDateReminders;
  final bool foalingAlerts;
  final bool emailNotifications;
  final AnimalType defaultSpecies;

  const AppSettings({
    this.dueDateReminders = true,
    this.foalingAlerts = true,
    this.emailNotifications = true,
    this.defaultSpecies = AnimalType.horse,
  });

  AppSettings copyWith({
    bool? dueDateReminders,
    bool? foalingAlerts,
    bool? emailNotifications,
    AnimalType? defaultSpecies,
  }) {
    return AppSettings(
      dueDateReminders: dueDateReminders ?? this.dueDateReminders,
      foalingAlerts: foalingAlerts ?? this.foalingAlerts,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      defaultSpecies: defaultSpecies ?? this.defaultSpecies,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  void toggleDueDateReminders(bool value) {
    state = state.copyWith(dueDateReminders: value);
  }

  void toggleFoalingAlerts(bool value) {
    state = state.copyWith(foalingAlerts: value);
  }

  void toggleEmailNotifications(bool value) {
    state = state.copyWith(emailNotifications: value);
  }

  void setDefaultSpecies(AnimalType type) {
    state = state.copyWith(defaultSpecies: type);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
