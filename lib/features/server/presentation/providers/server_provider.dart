import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/server_profile_model.dart';
import '../../data/datasources/lm_studio_api_service.dart';

enum ServerConnectionState { disconnected, connecting, connected }

class ServerConnectionStatus {
  final ServerConnectionState state;
  final String? detail;

  const ServerConnectionStatus(this.state, {this.detail});

  bool get isConnected => state == ServerConnectionState.connected;
  bool get isConnecting => state == ServerConnectionState.connecting;
}

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

final activeServerConnectionProvider =
    StreamProvider.autoDispose<ServerConnectionStatus>((ref) {
  final server = ref.watch(activeServerProvider);
  final apiService = ref.read(lmStudioApiProvider);

  if (server == null) {
    return Stream.value(const ServerConnectionStatus(ServerConnectionState.disconnected));
  }

  Future<ServerConnectionStatus> checkOnce() async {
    final ok = await apiService.ping(server);
    return ok
        ? const ServerConnectionStatus(ServerConnectionState.connected)
        : const ServerConnectionStatus(ServerConnectionState.disconnected);
  }

  Stream<ServerConnectionStatus> stream() async* {
    yield const ServerConnectionStatus(ServerConnectionState.connecting);
    yield await checkOnce();
    yield* Stream.periodic(const Duration(seconds: 3)).asyncMap((_) => checkOnce());
  }

  return stream().distinct((a, b) => a.state == b.state && a.detail == b.detail);
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
