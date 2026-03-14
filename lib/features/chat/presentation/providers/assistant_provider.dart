import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_locallm/features/settings/presentation/providers/settings_provider.dart';
import 'package:mobile_locallm/features/settings/data/models/settings_model.dart';
import 'package:mobile_locallm/core/services/foreground_service.dart';
import 'package:mobile_locallm/core/services/hotword_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

final assistantControllerProvider = Provider<AssistantController>((ref) {
  final foreground = ref.read(foregroundServiceProvider);
  final hotword = ref.read(hotwordServiceProvider);

  final controller = AssistantController(
    foreground: foreground,
    hotword: hotword,
  );

  // Listen MUST be registered synchronously during provider creation.
  ref.listen(settingsProvider, (previous, next) {
    controller.syncWithSettings(next, previous: previous);
  });

  // Initial sync (async) to start/stop based on persisted settings.
  Future.microtask(() async {
    await controller.syncWithSettings(ref.read(settingsProvider), previous: null, force: true);
  });

  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});

class AssistantController {
  final ForegroundService _foreground;
  final HotwordService _hotword;

  bool _isOperating = false;
  StreamSubscription<void>? _wakeSub;

  AssistantController({
    required ForegroundService foreground,
    required HotwordService hotword,
  })  : _foreground = foreground,
        _hotword = hotword;

  Future<void> syncWithSettings(
    SettingsModel next, {
    SettingsModel? previous,
    bool force = false,
  }) async {
    final accessKey = _resolveAccessKey(next);
    final shouldRun = next.isAssistantEnabled && accessKey.isNotEmpty;

    final prevAccessKey = previous == null ? '' : _resolveAccessKey(previous);
    final previouslyRunning = previous != null && previous.isAssistantEnabled && prevAccessKey.isNotEmpty;

    final configChanged = previous == null ||
        accessKey != prevAccessKey ||
        next.wakeWord != previous.wakeWord ||
        next.assistantSensitivity != previous.assistantSensitivity;

    if ((force || configChanged) && shouldRun) {
      await _startAssistant(next, accessKey: accessKey);
      return;
    }

    if (!shouldRun && previouslyRunning) {
      await _stopAssistant();
    }
  }

  String _resolveAccessKey(SettingsModel settings) {
    // Prefer `.env`, fall back to settings.
    try {
      final envKey = dotenv.maybeGet('PICOVOICE_ACCESS_KEY') ?? '';
      if (envKey.isNotEmpty) return envKey;
    } catch (_) {
      // `.env` might be absent or dotenv not initialized.
    }
    return settings.porcupineAccessKey;
  }

  Future<void> _startAssistant(SettingsModel settings, {required String accessKey}) async {
    if (_isOperating) return;
    _isOperating = true;
    try {
      // Ensure a clean state when restarting.
      await _stopAssistantInternal();

      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) return;

      // Best-effort: don't block if denied.
      try {
        await Permission.notification.request();
      } catch (_) {}

      await _foreground.initService();
      final fgOk = await _foreground.startService();
      if (!fgOk) return;

      final hotwordOk = await _hotword.initialize(
        accessKey,
        sensitivity: settings.assistantSensitivity,
        keywordString: settings.wakeWord,
      );
      if (!hotwordOk) {
        await _foreground.stopService();
        return;
      }

      await _hotword.start();

      await _wakeSub?.cancel();
      _wakeSub = _hotword.onWakeWord.listen((_) => _onWakeWordDetected());
    } catch (e, stack) {
      debugPrint('ASSISTANT ERROR during start: $e\n$stack');
    } finally {
      _isOperating = false;
    }
  }

  Future<void> _stopAssistant() async {
    if (_isOperating) return;
    _isOperating = true;
    try {
      await _stopAssistantInternal();
    } finally {
      _isOperating = false;
    }
  }

  Future<void> _stopAssistantInternal() async {
    try {
      await _wakeSub?.cancel();
      _wakeSub = null;
      await _hotword.stop();
      await _hotword.dispose();
      await _foreground.stopService();
    } catch (e) {
      debugPrint('ASSISTANT ERROR during stop: $e');
    }
  }

  Future<void> dispose() async {
    await _stopAssistantInternal();
  }

  void _onWakeWordDetected() {
    // Logic to handle wake word (e.g. bring app to foreground or open overlay)
    debugPrint('ASSISTANT: Wake word detected! How can I help?');
    // TODO: Trigger voice recognition or open chat overlay
  }
}
