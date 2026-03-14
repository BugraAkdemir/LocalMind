import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:porcupine_flutter/porcupine.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSection(
              title: 'Appearance',
              children: [
                _buildRadioTile(
                  title: 'Theme Mode',
                  subtitle: settings.themeMode.toUpperCase(),
                  icon: Icons.palette_outlined,
                  onTap: () => _showThemeDialog(context, ref),
                ),
                _buildRadioTile(
                  title: 'Text Size',
                  subtitle: settings.textSize.toUpperCase(),
                  icon: Icons.format_size,
                  onTap: () => _showTextSizeDialog(context, ref),
                ),
              ],
            ),
            _buildSection(
              title: 'System & Logic',
              children: [
                ListTile(
                  leading: const Icon(Icons.terminal_rounded, color: AppColors.textPrimary),
                  title: const Text('System Prompts'),
                  subtitle: const Text('Manage AI personalities and behavior'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  onTap: () => context.push('/prompts'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Experimental',
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.science_outlined, color: AppColors.textPrimary),
                  title: const Text('Beta Features'),
                  subtitle: const Text('Enable experimental features (Restart required)'),
                  value: settings.isBetaEnabled,
                  activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
                  activeThumbColor: AppColors.accent,
                  onChanged: (val) {
                    if (val) {
                      _showBetaWarningDialog(context, ref);
                    } else {
                      ref.read(settingsProvider.notifier).updateBetaStatus(false);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (settings.isBetaEnabled) ...[
              _buildSection(
                title: 'AI Preferences',
                children: [
                  ListTile(
                    leading: const Icon(Icons.record_voice_over, color: AppColors.textPrimary),
                    title: const Text('Voice Output'),
                    subtitle: const Text('Speak AI responses automatically'),
                    trailing: Switch(
                      value: settings.enableSpeech,
                      activeThumbColor: AppColors.accent,
                      onChanged: (val) {
                        ref.read(settingsProvider.notifier).updateSpeechStatus(val);
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.handyman_outlined, color: AppColors.textPrimary),
                    title: const Text('Enable AI Tools'),
                    subtitle: const Text('Allow AI to access battery/device info (Disable to hide tool prompts)'),
                    trailing: Switch(
                      value: settings.enableTools,
                      activeThumbColor: AppColors.accent,
                      onChanged: (val) {
                        ref.read(settingsProvider.notifier).updateEnableTools(val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Voice Assistant (Beta)',
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.mic, color: AppColors.textPrimary),
                    title: const Text('Wake Word Assistant'),
                    subtitle: const Text('Listen in background for voice commands'),
                    value: settings.isAssistantEnabled,
                    activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
                    activeThumbColor: AppColors.accent,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).updateAssistantStatus(val);
                    },
                  ),
                  if (settings.isAssistantEnabled) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Wake Word Keyword', 
                                     style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: BuiltInKeyword.values.any((k) => k.name == settings.wakeWord)
                                ? settings.wakeWord
                                : BuiltInKeyword.PORCUPINE.name,
                            dropdownColor: AppColors.surfaceLight,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.surfaceLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8), 
                                borderSide: BorderSide.none
                              ),
                            ),
                            items: BuiltInKeyword.values.map((k) => DropdownMenuItem(
                              value: k.name,
                              child: Text(k.name),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) ref.read(settingsProvider.notifier).updateWakeWord(val);
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Sensitivity Calibration', 
                                         style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              Text('${(settings.assistantSensitivity * 100).toInt()}%', 
                                   style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Slider(
                            value: settings.assistantSensitivity,
                            activeColor: AppColors.accent,
                            inactiveColor: AppColors.surfaceLight,
                            onChanged: (val) {
                              ref.read(settingsProvider.notifier).updateAssistantSensitivity(val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  ListTile(
                    leading: const Icon(Icons.vpn_key, color: AppColors.textPrimary),
                    title: const Text('Porcupine AccessKey'),
                    subtitle: Text(
                      settings.porcupineAccessKey.isEmpty
                          ? 'Not Set (Required for Wake Word)'
                          : '••••••••••••••••',
                      style: TextStyle(
                        color: settings.porcupineAccessKey.isEmpty ? AppColors.error : AppColors.textSecondary,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.help_outline, color: AppColors.accent, size: 20),
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

  Widget _buildSection({required String title, required List<Widget> children}) {
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
        GlassCard(
          child: Column(
            children: children,
          ),
        ),
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
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: const Text('Select Theme', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['light', 'dark', 'system'].map((mode) => RadioListTile<String>(
            title: Text(mode.toUpperCase(), style: const TextStyle(color: AppColors.textPrimary)),
            value: mode,
            groupValue: ref.watch(settingsProvider).themeMode,
            activeColor: AppColors.accent,
            onChanged: (val) {
              if (val != null) ref.read(settingsProvider.notifier).updateThemeMode(val);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showTextSizeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: const Text('Select Text Size', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['small', 'medium', 'large'].map((size) => RadioListTile<String>(
            title: Text(size.toUpperCase(), style: const TextStyle(color: AppColors.textPrimary)),
            value: size,
            groupValue: ref.watch(settingsProvider).textSize,
            activeColor: AppColors.accent,
            onChanged: (val) {
              if (val != null) ref.read(settingsProvider.notifier).updateTextSize(val);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showAccessKeyDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: ref.read(settingsProvider).porcupineAccessKey);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: const Text('Enter AccessKey', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Enter Picovoice AccessKey',
            hintStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).updatePorcupineAccessKey(controller.text);
              Navigator.pop(context);
            },
            child: const Text('SAVE', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showAccessKeyHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: const Text('How to get AccessKey?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Visit console.picovoice.ai', style: TextStyle(color: AppColors.textSecondary)),
            Text('2. Create a free account.', style: TextStyle(color: AppColors.textSecondary)),
            Text('3. Copy your "AccessKey" from the dashboard.', style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 16),
            Text('This key is required for the wake word engine to work offline.', 
                 style: TextStyle(color: AppColors.accent, fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showBetaWarningDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: const Text('Warning: Beta Features', style: TextStyle(color: AppColors.error)),
        content: const Text(
          'These features are experimental and may cause crashes or battery drain. Proceed with caution.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateBetaStatus(true);
              Navigator.pop(context);
            },
            child: const Text('I UNDERSTAND', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}
