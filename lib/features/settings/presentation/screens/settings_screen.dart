import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'App Preferences',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accentLight),
          ),
          const SizedBox(height: 8),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode, color: AppColors.textPrimary),
                  title: const Text('Theme'),
                  subtitle: Text(
                    ref.watch(settingsProvider).themeMode == 'system' 
                      ? 'System Default' 
                      : ref.watch(settingsProvider).themeMode == 'light' ? 'Light Mode' : 'Dark Mode'
                  ),
                  trailing: DropdownButton<String>(
                    value: ref.watch(settingsProvider).themeMode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'system', child: Text('System')),
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                      DropdownMenuItem(value: 'dark', child: Text('Dark')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(settingsProvider.notifier).updateThemeMode(val);
                      }
                    },
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: const Icon(Icons.format_size, color: AppColors.textPrimary),
                  title: const Text('Text Size'),
                  subtitle: Text(
                    ref.watch(settingsProvider).textSize == 'small'
                      ? 'Small'
                      : ref.watch(settingsProvider).textSize == 'large' ? 'Large' : 'Medium',
                  ),
                  trailing: DropdownButton<String>(
                    value: ref.watch(settingsProvider).textSize,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'small', child: Text('Small')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'large', child: Text('Large')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(settingsProvider.notifier).updateTextSize(val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Text(
            'Defaults & Advanced',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accentLight),
          ),
          const SizedBox(height: 8),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.tune, color: AppColors.textPrimary),
                  title: const Text('Generation Parameters'),
                  subtitle: const Text('Configure Temperature, Top-P, Tokens'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  onTap: () {
                    final notifier = ref.read(settingsProvider.notifier);
                    final state = ref.read(settingsProvider);
                    
                    double tempTemperature = state.defaultTemperature;
                    double tempTopP = state.defaultTopP;
                    int tempMaxTokens = state.defaultMaxTokens;

                    showDialog(
                      context: context,
                      builder: (context) => StatefulBuilder(
                        builder: (context, setStateDialog) {
                          return AlertDialog(
                            backgroundColor: AppColors.cardSurface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Generation Parameters'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Temperature: ${tempTemperature.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Text('Higher values make output more random.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  Slider(
                                    value: tempTemperature,
                                    min: 0.0,
                                    max: 2.0,
                                    divisions: 20,
                                    activeColor: AppColors.accent,
                                    onChanged: (val) => setStateDialog(() => tempTemperature = val),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  Text('Top-P: ${tempTopP.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Text('Nucleus sampling. 1.0 means consider all tokens.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  Slider(
                                    value: tempTopP,
                                    min: 0.0,
                                    max: 1.0,
                                    divisions: 20,
                                    activeColor: AppColors.accent,
                                    onChanged: (val) => setStateDialog(() => tempTopP = val),
                                  ),
                                  const SizedBox(height: 16),

                                  Text('Max Tokens: ${tempMaxTokens == -1 ? "Infinite" : tempMaxTokens}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Text('Maximum length of response.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  Slider(
                                    value: tempMaxTokens.toDouble(),
                                    min: -1.0,
                                    max: 4096.0,
                                    divisions: 4097,
                                    activeColor: AppColors.accent,
                                    onChanged: (val) {
                                      setStateDialog(() {
                                        if (val < 0) {
                                          tempMaxTokens = -1;
                                        } else {
                                          tempMaxTokens = val.toInt();
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                              ),
                              TextButton(
                                onPressed: () {
                                  notifier.updateDefaultTemperature(tempTemperature);
                                  notifier.updateDefaultTopP(tempTopP);
                                  notifier.updateDefaultMaxTokens(tempMaxTokens);
                                  Navigator.pop(context);
                                },
                                child: const Text('Save', style: TextStyle(color: AppColors.accent)),
                              ),
                            ],
                          );
                        }
                      ),
                    );
                  },
                ),
                 const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: const Icon(Icons.description, color: AppColors.textPrimary),
                  title: const Text('System Prompts'),
                  subtitle: const Text('Manage your default AI behaviors'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  onTap: () {
                    // Fix: Use GoRouter instead of Navigator.pushNamed
                    context.push('/prompts');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'About',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accentLight),
          ),
          const SizedBox(height: 8),
          const GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: AppColors.textPrimary),
                  title: Text('Version'),
                  subtitle: Text('1.0.0 (Beta)'),
                ),
                Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: Icon(Icons.code, color: AppColors.textPrimary),
                  title: Text('Open Source'),
                  subtitle: Text('GitHub Repository'),
                  trailing: Icon(Icons.open_in_new, size: 16, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
