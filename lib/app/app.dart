import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import '../core/router/app_router.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import '../features/chat/presentation/providers/assistant_provider.dart';

class LocalLMApp extends ConsumerWidget {
  const LocalLMApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsProvider);
    
    // Trigger Assistant Controller initialization
    ref.read(assistantControllerProvider);

    ThemeMode currentThemeMode;
    switch (settings.themeMode) {
      case 'light':
        currentThemeMode = ThemeMode.light;
        break;
      case 'dark':
        currentThemeMode = ThemeMode.dark;
        break;
      default:
        currentThemeMode = ThemeMode.system;
    }

    double textScale = 1.0;
    switch (settings.textSize) {
      case 'small':
        textScale = 0.85;
        break;
      case 'large':
        textScale = 1.15;
        break;
      case 'medium':
      default:
        textScale = 1.0;
        break;
    }

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: currentThemeMode == ThemeMode.light ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: currentThemeMode == ThemeMode.light ? Colors.white : const Color(0xFF0F0F14),
        systemNavigationBarIconBrightness: currentThemeMode == ThemeMode.light ? Brightness.dark : Brightness.light,
      ),
    );

    return MaterialApp.router(
      title: 'LocalLM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: currentThemeMode,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        );
      },
    );
  }
}
