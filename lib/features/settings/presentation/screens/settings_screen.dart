import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:porcupine_flutter/porcupine.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/settings_provider.dart';
import 'package:mobile_locallm/core/localization/app_i18n.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppI18n.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.settings,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSection(
              title: l10n.appearance,
              children: [
                _buildRadioTile(
                  title: l10n.language,
                  subtitle: settings.languageCode == 'tr' ? l10n.turkish : l10n.english,
                  icon: Icons.language_rounded,
                  onTap: () => _showLanguageDialog(context, ref),
                ),
                _buildRadioTile(
                  title: l10n.themeMode,
                  subtitle: _themeLabel(l10n, settings.themeMode),
                  icon: Icons.palette_outlined,
                  onTap: () => _showThemeDialog(context, ref),
                ),
                _buildRadioTile(
                  title: l10n.textSize,
                  subtitle: _textSizeLabel(l10n, settings.textSize),
                  icon: Icons.format_size,
                  onTap: () => _showTextSizeDialog(context, ref),
                ),
              ],
            ),
            _buildSection(
              title: l10n.systemAndLogic,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.terminal_rounded,
                    color: AppColors.textPrimary,
                  ),
                  title: Text(l10n.systemPromptsTitle),
                  subtitle: Text(l10n.manageAiPersonalities),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textMuted,
                  ),
                  onTap: () => context.push('/prompts'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: l10n.experimental,
              children: [
                SwitchListTile(
                  secondary: const Icon(
                    Icons.science_outlined,
                    color: AppColors.textPrimary,
                  ),
                  title: Text(l10n.betaFeatures),
                  subtitle: Text(l10n.enableExperimentalRestartRequired),
                  value: settings.isBetaEnabled,
                  activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
                  activeThumbColor: AppColors.accent,
                  onChanged: (val) {
                    if (val) {
                      _showBetaWarningDialog(context, ref);
                    } else {
                      ref
                          .read(settingsProvider.notifier)
                          .updateBetaStatus(false);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (settings.isBetaEnabled) ...[
              _buildSection(
                title: l10n.aiPreferences,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.record_voice_over,
                      color: AppColors.textPrimary,
                    ),
                    title: Text(l10n.voiceOutput),
                    subtitle: Text(l10n.speakResponsesAutomatically),
                    trailing: Switch(
                      value: settings.enableSpeech,
                      activeThumbColor: AppColors.accent,
                      onChanged: (val) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateSpeechStatus(val);
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.handyman_outlined,
                      color: AppColors.textPrimary,
                    ),
                    title: Text(l10n.enableAiTools),
                    subtitle: Text(l10n.enableToolsSubtitle),
                    trailing: Switch(
                      value: settings.enableTools,
                      activeThumbColor: AppColors.accent,
                      onChanged: (val) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateEnableTools(val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: l10n.voiceAssistantBeta,
                children: [
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.mic,
                      color: AppColors.textPrimary,
                    ),
                    title: Text(l10n.wakeWordAssistant),
                    subtitle: Text(l10n.listenInBackground),
                    value: settings.isAssistantEnabled,
                    activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
                    activeThumbColor: AppColors.accent,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateAssistantStatus(val);
                    },
                  ),
                  if (settings.isAssistantEnabled) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.wakeWordKeyword,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue:
                                BuiltInKeyword.values.any(
                                  (k) => k.name == settings.wakeWord,
                                )
                                ? settings.wakeWord
                                : BuiltInKeyword.PORCUPINE.name,
                            dropdownColor: AppColors.surfaceLight,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.surfaceLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: BuiltInKeyword.values
                                .map(
                                  (k) => DropdownMenuItem(
                                    value: k.name,
                                    child: Text(k.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateWakeWord(val);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.sensitivityCalibration,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${(settings.assistantSensitivity * 100).toInt()}%',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: settings.assistantSensitivity,
                            activeColor: AppColors.accent,
                            inactiveColor: AppColors.surfaceLight,
                            onChanged: (val) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .updateAssistantSensitivity(val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  ListTile(
                    leading: const Icon(
                      Icons.vpn_key,
                      color: AppColors.textPrimary,
                    ),
                    title: Text(l10n.porcupineAccessKey),
                    subtitle: Text(
                      settings.porcupineAccessKey.isEmpty
                          ? l10n.notSetRequiredForWakeWord
                          : '••••••••••••••••',
                      style: TextStyle(
                        color: settings.porcupineAccessKey.isEmpty
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.help_outline,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      onPressed: () => _showAccessKeyHelp(context),
                    ),
                    onTap: () => _showAccessKeyDialog(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        GlassCard(child: Column(children: children)),
      ],
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppI18n.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text(l10n.selectTheme, style: const TextStyle(color: AppColors.textPrimary)),
        content: RadioGroup<String>(
          groupValue: ref.watch(settingsProvider).themeMode,
          onChanged: (val) {
            if (val != null) {
              ref.read(settingsProvider.notifier).updateThemeMode(val);
            }
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['light', 'dark', 'system']
                .map(
                  (mode) => RadioListTile<String>(
                    title: Text(
                      _themeLabel(l10n, mode),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    value: mode,
                    activeColor: AppColors.accent,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showTextSizeDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppI18n.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text(l10n.selectTextSize, style: const TextStyle(color: AppColors.textPrimary)),
        content: RadioGroup<String>(
          groupValue: ref.watch(settingsProvider).textSize,
          onChanged: (val) {
            if (val != null) {
              ref.read(settingsProvider.notifier).updateTextSize(val);
            }
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['small', 'medium', 'large']
                .map(
                  (size) => RadioListTile<String>(
                    title: Text(
                      _textSizeLabel(l10n, size),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    value: size,
                    activeColor: AppColors.accent,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showAccessKeyDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppI18n.of(context);
    final controller = TextEditingController(
      text: ref.read(settingsProvider).porcupineAccessKey,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text(l10n.enterAccessKey, style: const TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: l10n.enterPicovoiceAccessKey,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel.toUpperCase(), style: const TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(settingsProvider.notifier)
                  .updatePorcupineAccessKey(controller.text);
              Navigator.pop(context);
            },
            child: Text(l10n.save.toUpperCase(), style: const TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showAccessKeyHelp(BuildContext context) {
    final l10n = AppI18n.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text(l10n.howToGetAccessKey, style: const TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.accessKeyStep1,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            Text(
              l10n.accessKeyStep2,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            Text(
              l10n.accessKeyStep3,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.accessKeyRequiredOffline,
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.gotIt.toUpperCase(), style: const TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showBetaWarningDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppI18n.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text(l10n.betaWarningTitleShort, style: const TextStyle(color: AppColors.error)),
        content: Text(l10n.betaWarningBodyShort, style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel.toUpperCase(), style: const TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateBetaStatus(true);
              Navigator.pop(context);
            },
            child: Text(l10n.iUnderstand.toUpperCase(), style: const TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppI18n.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text(l10n.language, style: const TextStyle(color: AppColors.textPrimary)),
        content: RadioGroup<String>(
          groupValue: ref.watch(settingsProvider).languageCode,
          onChanged: (val) {
            if (val != null) {
              ref.read(settingsProvider.notifier).updateLanguage(val);
            }
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(l10n.english,
                    style: const TextStyle(color: AppColors.textPrimary)),
                value: 'en',
                activeColor: AppColors.accent,
              ),
              RadioListTile<String>(
                title: Text(l10n.turkish,
                    style: const TextStyle(color: AppColors.textPrimary)),
                value: 'tr',
                activeColor: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _themeLabel(AppI18n l10n, String value) {
    switch (value) {
      case 'light':
        return l10n.light;
      case 'dark':
        return l10n.dark;
      default:
        return l10n.system;
    }
  }

  String _textSizeLabel(AppI18n l10n, String value) {
    switch (value) {
      case 'small':
        return l10n.small;
      case 'large':
        return l10n.large;
      default:
        return l10n.medium;
    }
  }
}
