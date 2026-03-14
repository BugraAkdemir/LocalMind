import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'tool_model.dart';

final toolRegistryProvider = Provider<ToolRegistry>((ref) {
  return ToolRegistry();
});

class ToolRegistry {
  final List<ToolModel> _tools = [];

  ToolRegistry() {
    _registerDefaultTools();
  }

  List<ToolModel> get tools => List.unmodifiable(_tools);

  void _registerDefaultTools() {
    // 1. Check Battery Tool
    _tools.add(ToolModel(
      name: 'get_battery_status',
      description: 'Check the current battery level and charging state of the mobile device.',
      parameters: {
        'type': 'object',
        'properties': {},
      },
      onExecute: (args) async {
        final battery = Battery();
        final level = await battery.batteryLevel;
        final state = await battery.batteryState;
        return 'The battery is at $level% and is currently ${state.name}.';
      },
    ));

    // 2. Get Device Info Tool
    _tools.add(ToolModel(
      name: 'get_device_info',
      description: 'Get basic information about the phone hardware and OS version.',
      parameters: {
        'type': 'object',
        'properties': {},
      },
      onExecute: (args) async {
        final deviceInfo = DeviceInfoPlugin();
        String info = '';
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          info = 'Android Device: ${androidInfo.model}, Manufacturer: ${androidInfo.manufacturer}, OS Version: ${androidInfo.version.release}';
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          info = 'iOS Device: ${iosInfo.name}, Model: ${iosInfo.model}, OS Version: ${iosInfo.systemVersion}';
        }
        return info;
      },
    ));
  }
}
