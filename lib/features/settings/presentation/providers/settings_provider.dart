import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/settings_model.dart';

final settingsBoxProvider = Provider<Box<SettingsModel>>((ref) {
  return Hive.box<SettingsModel>('settings');
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return SettingsNotifier(box);
});

class SettingsNotifier extends StateNotifier<SettingsModel> {
  final Box<SettingsModel> _box;

  SettingsNotifier(this._box) : super(_getInitialSettings(_box));

  static SettingsModel _getInitialSettings(Box<SettingsModel> box) {
    if (box.isEmpty) {
      final defaultSettings = SettingsModel();
      box.put('app_settings', defaultSettings);
      return defaultSettings;
    }
    return box.get('app_settings') ?? SettingsModel();
  }

  Future<void> updateThemeMode(String mode) async {
    final newSettings = state.copyWith(themeMode: mode);
    state = newSettings;
    await _box.put('app_settings', newSettings);
  }

  Future<void> updateTextSize(String size) async {
    final newSettings = state.copyWith(textSize: size);
    state = newSettings;
    await _box.put('app_settings', newSettings);
  }

  Future<void> updateEnableSpeech(bool enable) async {
    final newSettings = state.copyWith(enableSpeech: enable);
    state = newSettings;
    await _box.put('app_settings', newSettings);
  }

  Future<void> updateGenerationParams({
    double? temperature,
    double? topP,
    int? maxTokens,
  }) async {
    final newSettings = state.copyWith(
      defaultTemperature: temperature,
      defaultTopP: topP,
      defaultMaxTokens: maxTokens,
    );
    state = newSettings;
    await _box.put('app_settings', newSettings);
  }

  Future<void> updateDefaultTemperature(double temperature) async {
    final newSettings = state.copyWith(defaultTemperature: temperature);
    state = newSettings;
    await _box.put('app_settings', newSettings);
  }

  Future<void> updateDefaultTopP(double topP) async {
    final newSettings = state.copyWith(defaultTopP: topP);
    state = newSettings;
    await _box.put('app_settings', newSettings);
  }

  Future<void> updateDefaultMaxTokens(int maxTokens) async {
    final newSettings = state.copyWith(defaultMaxTokens: maxTokens);
    state = newSettings;
    await _box.put('app_settings', newSettings);
  }
}
