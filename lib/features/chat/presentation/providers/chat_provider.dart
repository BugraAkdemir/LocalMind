import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../../server/presentation/providers/server_provider.dart';
import '../../../server/data/datasources/lm_studio_api_service.dart';
import '../../../prompts/presentation/providers/prompt_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

final conversationBoxProvider = Provider<Box<ConversationModel>>((ref) {
  return Hive.box<ConversationModel>('conversations');
});

final conversationsProvider = StateNotifierProvider<ConversationsNotifier, List<ConversationModel>>((ref) {
  return ConversationsNotifier(ref.watch(conversationBoxProvider));
});

final activeConversationIdProvider = StateProvider<String?>((ref) => null);

final activeConversationProvider = Provider<ConversationModel?>((ref) {
  final id = ref.watch(activeConversationIdProvider);
  if (id == null) return null;
  final conversations = ref.watch(conversationsProvider);
  try {
    return conversations.firstWhere((c) => c.id == id);
  } catch (e) {
    return null;
  }
});

class ConversationsNotifier extends StateNotifier<List<ConversationModel>> {
  final Box<ConversationModel> _box;

  ConversationsNotifier(this._box) : super(_box.values.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));

  Future<ConversationModel> createConversation({String? title}) async {
    final id = const Uuid().v4();
    final conversation = ConversationModel(
      id: id,
      title: title ?? 'New Conversation',
    );
    await _box.put(id, conversation);
    _updateState();
    return conversation;
  }

  Future<void> addMessage(String conversationId, MessageModel message) async {
    final conversation = _box.get(conversationId);
    if (conversation != null) {
      conversation.messages.add(message);
      conversation.updatedAt = DateTime.now();
      
      // Auto-generate title from first user message if title is default
      if (conversation.title == 'New Conversation' && message.role == 'user') {
        conversation.title = _generateTitleFromMessage(message.content);
      }
      
      await conversation.save();
      _updateState();
    }
  }

  Future<void> updateMessage(String conversationId, MessageModel updatedMessage) async {
    final conversation = _box.get(conversationId);
    if (conversation != null) {
      final index = conversation.messages.indexWhere((m) => m.id == updatedMessage.id);
      if (index != -1) {
        conversation.messages[index] = updatedMessage;
        await conversation.save();
        _updateState();
      }
    }
  }

  Future<void> updateTitle(String id, String newTitle) async {
    final conversation = _box.get(id);
    if (conversation != null) {
      conversation.title = newTitle;
      await conversation.save();
      _updateState();
    }
  }

  Future<void> deleteConversation(String id) async {
    await _box.delete(id);
    _updateState();
  }

  void _updateState() {
    final list = _box.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    state = list;
  }

  String _generateTitleFromMessage(String content) {
    final words = content.trim().split(RegExp(r'\s+'));
    if (words.length <= 4) return content.trim();
    return '${words.take(4).join(' ')}...';
  }
}

// Global provider for sending messages to the active server
final chatControllerProvider = Provider<ChatController>((ref) {
  return ChatController(ref);
});

class ChatController {
  final Ref _ref;
  CancelToken? _activeCancelToken;

  ChatController(this._ref);

  void stopGeneration() {
    _activeCancelToken?.cancel('User stopped generation');
    _activeCancelToken = null;
  }

  Future<void> sendMessage(String text, {String? imagePath}) async {
    final activeServer = _ref.read(activeServerProvider);
    if (activeServer == null) throw Exception('No active server selected');

    var conversationId = _ref.read(activeConversationIdProvider);
    final conversationsNotifier = _ref.read(conversationsProvider.notifier);
    final activeSystemPrompt = _ref.read(activeSystemPromptProvider);
    final appSettings = _ref.read(settingsProvider);

    // Create a new conversation if none is active
    if (conversationId == null) {
      final newConv = await conversationsNotifier.createConversation();
      conversationId = newConv.id;
      _ref.read(activeConversationIdProvider.notifier).state = conversationId;
    }

    final conversation = _ref.read(activeConversationProvider);
    if (conversation == null) return;

    // 1. Add User Message
    final userMessage = MessageModel(
      id: const Uuid().v4(),
      role: 'user',
      content: text,
      imagePath: imagePath,
    );
    await conversationsNotifier.addMessage(conversationId, userMessage);

    // 2. Add empty Assistant Message (marked as streaming)
    final assistantMessageId = const Uuid().v4();
    var assistantMessage = MessageModel(
      id: assistantMessageId,
      role: 'assistant',
      content: '',
      isStreaming: true,
    );
    await conversationsNotifier.addMessage(conversationId, assistantMessage);

    // 3. Start Streaming from API
    final apiService = _ref.read(lmStudioApiProvider);
    final modelId = conversation.modelId ?? 'local-model'; // Fallback if no model selected
    final systemPrompt = activeSystemPrompt?.content; // Hooked up

    _activeCancelToken = CancelToken();

    try {
      final stream = apiService.streamChatCompletion(
        server: activeServer,
        modelId: modelId,
        messages: conversation.messages.where((m) => !m.isStreaming || m.id == assistantMessageId).toList(),
        systemPrompt: systemPrompt,
        temperature: appSettings.defaultTemperature,
        topP: appSettings.defaultTopP,
        maxTokens: appSettings.defaultMaxTokens,
        cancelToken: _activeCancelToken,
      );

      final buffer = StringBuffer();
      
      await for (final chunk in stream) {
        buffer.write(chunk);
        
        // Every few chunks, update the UI (Hive save is fast enough)
        assistantMessage = assistantMessage.copyWith(
          content: buffer.toString(),
        );
        await conversationsNotifier.updateMessage(conversationId, assistantMessage);
      }

      // 4. Stream finished
      assistantMessage = assistantMessage.copyWith(
        content: buffer.toString(),
        isStreaming: false,
      );
      await conversationsNotifier.updateMessage(conversationId, assistantMessage);

    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        // Just clean up, don't show as error
      } else {
        // Stream failed - update message with error
        assistantMessage = assistantMessage.copyWith(
          content: '${assistantMessage.content}\n\n[ERROR: ${e.toString()}]',
          isStreaming: false,
        );
        await conversationsNotifier.updateMessage(conversationId, assistantMessage);
      }
    } finally {
      // Mark as not streaming anymore even if cancelled
      final finalConv = _ref.read(activeConversationProvider);
      if (finalConv != null) {
        final lastMsg = finalConv.messages.last;
        if (lastMsg.id == assistantMessageId && lastMsg.isStreaming) {
           await conversationsNotifier.updateMessage(conversationId, lastMsg.copyWith(isStreaming: false));
        }
      }
      _activeCancelToken = null;
    }
  }

  Future<void> clearCurrentConversation() async {
    final conversationId = _ref.read(activeConversationIdProvider);
    if (conversationId == null) return;

    final conversation = _ref.read(activeConversationProvider);
    if (conversation != null) {
      conversation.messages.clear();
      conversation.updatedAt = DateTime.now();
      await conversation.save();
      
      // Update the UI state
      _ref.read(conversationsProvider.notifier)._updateState();
    }
  }
}
