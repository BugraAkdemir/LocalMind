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

  SettingsModel({
    this.themeMode = 'dark', // Default to our OLED-optimized theme
    this.textSize = 'medium',
    this.enableSpeech = true,
    this.defaultTemperature = 0.7,
    this.defaultTopP = 1.0,
    this.defaultMaxTokens = -1,
  });

  SettingsModel copyWith({
    String? themeMode,
    String? textSize,
    bool? enableSpeech,
    double? defaultTemperature,
    double? defaultTopP,
    int? defaultMaxTokens,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      textSize: textSize ?? this.textSize,
      enableSpeech: enableSpeech ?? this.enableSpeech,
      defaultTemperature: defaultTemperature ?? this.defaultTemperature,
      defaultTopP: defaultTopP ?? this.defaultTopP,
      defaultMaxTokens: defaultMaxTokens ?? this.defaultMaxTokens,
    );
  }
}
