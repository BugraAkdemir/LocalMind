import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../server/presentation/providers/server_provider.dart';
import '../../../server/data/datasources/lm_studio_api_service.dart';

final availableModelsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final activeServer = ref.watch(activeServerProvider);
  if (activeServer == null) throw Exception('No active server');

  final apiService = ref.read(lmStudioApiProvider);
  return await apiService.getModels(activeServer);
});

final selectedModelIdProvider = StateProvider<String?>((ref) => null);
