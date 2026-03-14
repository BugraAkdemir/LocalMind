import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:porcupine_flutter/porcupine_error.dart';
import 'package:porcupine_flutter/porcupine.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

final hotwordServiceProvider = Provider<HotwordService>((ref) {
  return HotwordService();
});

class HotwordService {
  PorcupineManager? _porcupineManager;
  final _wakeWordController = StreamController<void>.broadcast();

  HotwordService();

  Stream<void> get onWakeWord => _wakeWordController.stream;

  Future<bool> initialize(String accessKey, {double sensitivity = 0.5, String keywordString = 'PORCUPINE'}) async {
    try {
      debugPrint('HOTWORD: BREADCRUMB H1 - Init called with accessKey: ${accessKey.substring(0, 4)}...');
      // Clean up previous instance
      await dispose();
      debugPrint('HOTWORD: BREADCRUMB H2 - Old manager disposed');

      // Find matching built-in keyword enum
      BuiltInKeyword keyword;
      try {
        keyword = BuiltInKeyword.values.firstWhere(
          (e) => e.name == keywordString,
          orElse: () => BuiltInKeyword.PORCUPINE,
        );
      } catch (e) {
        debugPrint('HOTWORD: BREADCRUMB H3 - Enum search error: $e');
        keyword = BuiltInKeyword.PORCUPINE;
      }
      debugPrint('HOTWORD: BREADCRUMB H4 - Keyword resolved to: $keyword');

      debugPrint('HOTWORD: BREADCRUMB H5 - Calling fromBuiltInKeywords...');
      _porcupineManager = await PorcupineManager.fromBuiltInKeywords(
        accessKey,
        [keyword],
        _onWakeWordDetected,
        sensitivities: [sensitivity],
      );
      debugPrint('HOTWORD: BREADCRUMB H6 - Native manager created successfully');
      return true;
    } on PorcupineException catch (e) {
      debugPrint('HOTWORD ERROR (Porcupine): ${e.message}');
      return false;
    } catch (e) {
      debugPrint('HOTWORD UNKNOWN ERROR: $e');
      return false;
    }
  }

  void _onWakeWordDetected(int keywordIndex) {
    debugPrint('Wake word detected! Index: $keywordIndex');
    _wakeWordController.add(null);
  }

  Future<void> start() async {
    await _porcupineManager?.start();
  }

  Future<void> stop() async {
    await _porcupineManager?.stop();
  }

  Future<void> dispose() async {
    try {
      if (_porcupineManager != null) {
        debugPrint('HOTWORD: Disposing manager...');
        await stop();
        await _porcupineManager?.delete();
        _porcupineManager = null;
        debugPrint('HOTWORD: Manager disposed.');
      }
    } catch (e) {
      debugPrint('HOTWORD ERROR during dispose: $e');
    }
  }
}
