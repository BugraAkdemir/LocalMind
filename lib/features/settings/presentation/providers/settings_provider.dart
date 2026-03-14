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

  Future<void> updateSpeechStatus(bool enable) async {
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

  Future<void> updateAssistantStatus(bool enable) async {
    final newSettings = state.copyWith(isAssistantEnabled: enable);
    state = newSettings;
    await _box.put('app_settings', newSettings);
  }

  Future<void> updatePorcupineAccessKey(String key) async {
    state = state.copyWith(porcupineAccessKey: key);
    await _box.put('app_settings', state);
  }

  Future<void> updateAssistantSensitivity(double value) async {
    state = state.copyWith(assistantSensitivity: value);
    await _box.put('app_settings', state);
  }

  Future<void> updateWakeWord(String keyword) async {
    state = state.copyWith(wakeWord: keyword);
    await _box.put('app_settings', state);
  }

  Future<void> updateEnableTools(bool enable) async {
    state = state.copyWith(enableTools: enable);
    await _box.put('app_settings', state);
  }

  Future<void> updateBetaStatus(bool enable) async {
    if (!enable) {
      // Force reset all beta-dependent features to false when beta is disabled
      state = state.copyWith(
        isBetaEnabled: false,
        enableSpeech: false,
        enableTools: false,
        isAssistantEnabled: false,
      );
    } else {
      state = state.copyWith(isBetaEnabled: true);
    }
    await _box.put('app_settings', state);
  }
}
