import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import '../core/router/app_router.dart';
import '../core/widgets/app_backdrop.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import '../features/chat/presentation/providers/assistant_provider.dart';
import 'package:mobile_locallm/core/localization/app_i18n.dart';

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
        systemNavigationBarColor: currentThemeMode == ThemeMode.light ? Colors.white : const Color(0xFF0E1011),
        systemNavigationBarIconBrightness: currentThemeMode == ThemeMode.light ? Brightness.dark : Brightness.light,
      ),
    );

    return MaterialApp.router(
      onGenerateTitle: (context) => AppI18n.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: currentThemeMode,
      locale: Locale(settings.languageCode),
      supportedLocales: AppI18n.supportedLocales,
      localizationsDelegates: [
        AppI18n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        final scaled = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        );

        // Global premium backdrop (subtle gradients, no neon).
        return AppBackdrop(child: scaled);
      },
    );
  }
}
