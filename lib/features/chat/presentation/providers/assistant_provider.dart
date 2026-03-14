import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_locallm/features/settings/presentation/providers/settings_provider.dart';
import 'package:mobile_locallm/core/services/foreground_service.dart';
import 'package:mobile_locallm/core/services/hotword_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final assistantControllerProvider = Provider<AssistantController>((ref) {
  return AssistantController(ref);
});

class AssistantController {
  final Ref _ref;
  bool _isOperating = false;

  AssistantController(this._ref) {
    _init();
  }

  Future<void> _init() async {
    // Initialize service configuration once
    try {
      final foreground = _ref.read(foregroundServiceProvider);
      await foreground.initService();
      debugPrint('ASSISTANT: Foreground service initialized.');
    } catch (e) {
      debugPrint('ASSISTANT ERROR during initService: $e');
    }

    // Listen to settings changes to start/stop or re-initialize the assistant
    _ref.listen(settingsProvider, (previous, next) {
      final wasEnabled = previous?.isAssistantEnabled ?? false;
      final isEnabled = next.isAssistantEnabled;
      final keyChanged = next.porcupineAccessKey != previous?.porcupineAccessKey;
      final wordChanged = next.wakeWord != previous?.wakeWord;
      final sensChanged = next.assistantSensitivity != previous?.assistantSensitivity;

      if (isEnabled != wasEnabled || (isEnabled && (keyChanged || wordChanged || sensChanged))) {
        if (isEnabled && next.porcupineAccessKey.isNotEmpty) {
          debugPrint('ASSISTANT: Restarting/Starting due to setting change...');
          _startAssistant();
        } else if (!isEnabled && wasEnabled) {
          debugPrint('ASSISTANT: Stopping assistant...');
          _stopAssistant();
        }
      }
    });

    // Check initial state
    final settings = _ref.read(settingsProvider);
    if (settings.isAssistantEnabled && settings.porcupineAccessKey.isNotEmpty) {
      _startAssistant();
    }
  }

  Future<void> _startAssistant() async {
    if (_isOperating) {
      debugPrint('ASSISTANT: Operation in progress, skipping start request.');
      return;
    }
    _isOperating = true;
    try {
      debugPrint('ASSISTANT: BREADCRUMB 1 - Starting');
      final settings = _ref.read(settingsProvider);
      
      // Prioritize .env key safely
      String accessKey = '';
      try {
        accessKey = dotenv.maybeGet('PICOVOICE_ACCESS_KEY') ?? '';
      } catch (_) {
        debugPrint('ASSISTANT: DotEnv not initialized, using settings.');
      }

      if (accessKey.isEmpty) {
        accessKey = settings.porcupineAccessKey;
      }
      
      debugPrint('ASSISTANT: BREADCRUMB 2 - Settings read (Key present: ${accessKey.isNotEmpty})');

      if (accessKey.isEmpty) {
        debugPrint('ASSISTANT: BREADCRUMB 3 - Key missing');
        _isOperating = false;
        return;
      }
      
      debugPrint('ASSISTANT: BREADCRUMB 4 - Requesting permissions');
      final micStatus = await Permission.microphone.request();
      debugPrint('ASSISTANT: BREADCRUMB 5 - Mic status: $micStatus');
      
      if (!micStatus.isGranted) {
        debugPrint('ASSISTANT: BREADCRUMB 6 - Mic denied');
        _isOperating = false;
        return;
      }

      final notificationStatus = await Permission.notification.request();
      debugPrint('ASSISTANT: BREADCRUMB 7 - Notif status: $notificationStatus');

      final foreground = _ref.read(foregroundServiceProvider);
      final hotword = _ref.read(hotwordServiceProvider);

      debugPrint('ASSISTANT: BREADCRUMB 8 - Preparing hotword engine');
      try {
        await hotword.stop();
        await hotword.dispose();
      } catch (e) {
        debugPrint('ASSISTANT: BREADCRUMB 9 - Cleanup error (minor): $e');
      }

      debugPrint('ASSISTANT: BREADCRUMB 10 - Starting foreground service');
      await foreground.initService(); // Re-init just in case
      await Future.delayed(const Duration(milliseconds: 500));
      final success = await foreground.startService();
      debugPrint('ASSISTANT: BREADCRUMB 11 - Foreground success: $success');
      
      if (success) {
        debugPrint('ASSISTANT: BREADCRUMB 12 - Initializing hotword');
        final hotwordInitialized = await hotword.initialize(
          accessKey,
          sensitivity: settings.assistantSensitivity,
          keywordString: settings.wakeWord,
        );
        
        if (hotwordInitialized) {
          debugPrint('ASSISTANT: BREADCRUMB 13 - Starting hotword capture');
          await hotword.start();
          debugPrint('ASSISTANT: BREADCRUMB 14 - Active');
          
          // Listen for wake word
          hotword.onWakeWord.listen((_) {
            _onWakeWordDetected();
          });
        } else {
          debugPrint('ASSISTANT: BREADCRUMB 15 - Hotword init failed');
        }
      }
    } catch (e, stack) {
      debugPrint('ASSISTANT CRITICAL ERROR during _start: $e\n$stack');
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
      debugPrint('ASSISTANT: Stopping and disposing local services...');
      final foreground = _ref.read(foregroundServiceProvider);
      final hotword = _ref.read(hotwordServiceProvider);

      await hotword.stop();
      await hotword.dispose();
      await foreground.stopService();
      debugPrint('ASSISTANT: All services stopped.');
    } catch (e) {
      debugPrint('ASSISTANT ERROR during _stopInternal: $e');
    }
  }

  void _onWakeWordDetected() {
    // Logic to handle wake word (e.g. bring app to foreground or open overlay)
    debugPrint('ASSISTANT: Wake word detected! How can I help?');
    // TODO: Trigger voice recognition or open chat overlay
  }
}
