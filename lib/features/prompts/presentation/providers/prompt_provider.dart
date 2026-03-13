import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/system_prompt_model.dart';

final systemPromptBoxProvider = Provider<Box<SystemPromptModel>>((ref) {
  return Hive.box<SystemPromptModel>('prompts');
});

final systemPromptsProvider = StateNotifierProvider<SystemPromptsNotifier, List<SystemPromptModel>>((ref) {
  return SystemPromptsNotifier(ref.watch(systemPromptBoxProvider));
});

final activeSystemPromptIdProvider = StateProvider<String?>((ref) => null);

final activeSystemPromptProvider = Provider<SystemPromptModel?>((ref) {
  final id = ref.watch(activeSystemPromptIdProvider);
  if (id == null) return null;
  final prompts = ref.watch(systemPromptsProvider);
  try {
    return prompts.firstWhere((p) => p.id == id);
  } catch (e) {
    return null;
  }
});

class SystemPromptsNotifier extends StateNotifier<List<SystemPromptModel>> {
  final Box<SystemPromptModel> _box;

  SystemPromptsNotifier(this._box) : super(_box.values.toList());

  Future<void> addPrompt(SystemPromptModel prompt) async {
    await _box.put(prompt.id, prompt);
    state = _box.values.toList();
  }

  Future<void> updatePrompt(SystemPromptModel prompt) async {
    await _box.put(prompt.id, prompt);
    state = _box.values.toList();
  }

  Future<void> deletePrompt(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }
}
