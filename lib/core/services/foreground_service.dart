import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

final foregroundServiceProvider = Provider<ForegroundService>((ref) {
  return ForegroundService(ref);
});

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) {
    // Initialize things if needed in the isolate
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    // Periodic tasks
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    // Cleanup
  }
}

class ForegroundService {
  ForegroundService(Ref ref);

  Future<void> initService() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'assistant_service',
        channelName: 'Assistant Service',
        channelDescription: 'Listening for Wake Word',
        channelImportance: NotificationChannelImportance.MAX,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> startService() async {
    try {
      if (await FlutterForegroundTask.isRunningService) {
        debugPrint('FOREGROUND: Service already running.');
        return true;
      }

      final result = await FlutterForegroundTask.startService(
        notificationTitle: 'LocalMind Assistant Active',
        notificationText: 'Listening for wake word...',
        callback: startCallback,
      );
      
      debugPrint('FOREGROUND: Start result: ${result.success}');
      
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      return result.success;
    } catch (e) {
      debugPrint('FOREGROUND ERROR during startService: $e');
      return false;
    }
  }

  Future<void> stopService() async {
    await FlutterForegroundTask.stopService();
  }
}
