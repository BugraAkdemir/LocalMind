import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/server_profile_model.dart';
import '../../data/datasources/lm_studio_api_service.dart';

final serverBoxProvider = Provider<Box<ServerProfileModel>>((ref) {
  return Hive.box<ServerProfileModel>('servers');
});

final serversProvider = StateNotifierProvider<ServersNotifier, List<ServerProfileModel>>((ref) {
  return ServersNotifier(ref.watch(serverBoxProvider));
});

final activeServerProvider = Provider<ServerProfileModel?>((ref) {
  final servers = ref.watch(serversProvider);
  try {
    return servers.firstWhere((s) => s.isActive);
  } catch (e) {
    return null;
  }
});

class ServersNotifier extends StateNotifier<List<ServerProfileModel>> {
  final Box<ServerProfileModel> _box;

  ServersNotifier(this._box) : super(_box.values.toList());

  Future<void> addServer(ServerProfileModel server) async {
    // If this is the first server, make it active automatically
    if (state.isEmpty) {
      server.isActive = true;
    }
    
    await _box.put(server.id, server);
    state = _box.values.toList();
  }

  Future<void> updateServer(ServerProfileModel server) async {
    await _box.put(server.id, server);
    state = _box.values.toList();
  }

  Future<void> deleteServer(String id) async {
    final server = _box.get(id);
    await _box.delete(id);
    
    state = _box.values.toList();
    
    // If we deleted the active server, make another one active if available
    if (server?.isActive == true && state.isNotEmpty) {
      await setActiveServer(state.first.id);
    }
  }

  Future<void> setActiveServer(String id) async {
    for (var server in state) {
      if (server.id == id) {
        server.isActive = true;
        server.lastConnected = DateTime.now();
      } else {
        server.isActive = false;
      }
      await _box.put(server.id, server);
    }
    state = _box.values.toList();
  }
}

final connectionTestProvider = FutureProvider.family<bool, ServerProfileModel>((ref, server) async {
  final apiService = ref.read(lmStudioApiProvider);
  try {
    await apiService.testConnection(server);
    return true;
  } catch (e) {
    throw e.toString();
  }
});
