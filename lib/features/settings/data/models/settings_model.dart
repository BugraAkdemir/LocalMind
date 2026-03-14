import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 4)
class SettingsModel extends HiveObject {
  @HiveField(0)
  String themeMode; // 'system', 'light', 'dark'

  @HiveField(1)
  String textSize; // 'small', 'medium', 'large'

  @HiveField(2)
  bool enableSpeech;

  @HiveField(3)
  double defaultTemperature;

  @HiveField(4)
  double defaultTopP;

  @HiveField(5)
  int defaultMaxTokens;

  @HiveField(6, defaultValue: false)
  bool isAssistantEnabled;

  @HiveField(7, defaultValue: '')
  String porcupineAccessKey;

  @HiveField(8, defaultValue: 0.5)
  double assistantSensitivity;

  @HiveField(9, defaultValue: 'PORCUPINE')
  String wakeWord;

  @HiveField(10, defaultValue: true)
  bool enableTools;

  @HiveField(11, defaultValue: false)
  bool isBetaEnabled;

  @HiveField(12, defaultValue: 'en')
  String languageCode; // 'en', 'tr'

  SettingsModel({
    this.themeMode = 'dark',
    this.textSize = 'medium',
    this.enableSpeech = true,
    this.defaultTemperature = 0.7,
    this.defaultTopP = 1.0,
    this.defaultMaxTokens = -1,
    this.isAssistantEnabled = false,
    this.porcupineAccessKey = '',
    this.assistantSensitivity = 0.5,
    this.wakeWord = 'PORCUPINE',
    this.enableTools = true,
    this.isBetaEnabled = false,
    this.languageCode = 'en',
  });

  SettingsModel copyWith({
    String? themeMode,
    String? textSize,
    bool? enableSpeech,
    double? defaultTemperature,
    double? defaultTopP,
    int? defaultMaxTokens,
    bool? isAssistantEnabled,
    String? porcupineAccessKey,
    double? assistantSensitivity,
    String? wakeWord,
    bool? enableTools,
    bool? isBetaEnabled,
    String? languageCode,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      textSize: textSize ?? this.textSize,
      enableSpeech: enableSpeech ?? this.enableSpeech,
      defaultTemperature: defaultTemperature ?? this.defaultTemperature,
      defaultTopP: defaultTopP ?? this.defaultTopP,
      defaultMaxTokens: defaultMaxTokens ?? this.defaultMaxTokens,
      isAssistantEnabled: isAssistantEnabled ?? this.isAssistantEnabled,
      porcupineAccessKey: porcupineAccessKey ?? this.porcupineAccessKey,
      assistantSensitivity: assistantSensitivity ?? this.assistantSensitivity,
      wakeWord: wakeWord ?? this.wakeWord,
      enableTools: enableTools ?? this.enableTools,
      isBetaEnabled: isBetaEnabled ?? this.isBetaEnabled,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
