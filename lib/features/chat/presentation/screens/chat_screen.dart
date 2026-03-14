import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../../../server/presentation/providers/server_provider.dart';
import '../../../../core/widgets/connection_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // Because ListView is reversed
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend(String text, String? imagePath) {
    ref.read(chatControllerProvider).sendMessage(text, imagePath: imagePath);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final activeConversation = ref.watch(activeConversationProvider);
    final activeServer = ref.watch(activeServerProvider);
    final serverConn = ref.watch(activeServerConnectionProvider);
    
    // Determine if we are currently waiting for a stream based on the last message
    final messages = activeConversation?.messages ?? [];
    final isGenerating = messages.isNotEmpty && messages.last.isStreaming;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activeConversation?.title ?? 'New Chat',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                ConnectionIndicator(
                  isConnected: serverConn.valueOrNull?.isConnected ?? false,
                  isConnecting: serverConn.isLoading || (serverConn.valueOrNull?.isConnecting ?? false),
                  size: 6,
                ),
                const SizedBox(width: 4),
                Text(
                  activeServer?.name ?? 'No Server Connected',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dns_rounded),
            tooltip: 'Server Connection',
            onPressed: () => context.push('/servers'),
          ),
          IconButton(
            icon: const Icon(Icons.memory_rounded),
            tooltip: 'Model Selection',
            onPressed: () => context.push('/models'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'clear') {
                if (activeConversation != null && activeConversation.messages.isNotEmpty) {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.cardSurface,
                      title: const Text('Clear Chat History?'),
                      content: const Text('This will delete all messages in the current conversation.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref.read(chatControllerProvider).clearCurrentConversation();
                  }
                }
              } else if (value == 'settings') {
                context.push('/settings');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'clear', child: Text('Clear History')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(context, ref),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Start from bottom
                    padding: const EdgeInsets.only(bottom: 16, top: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      // Reverse index because of reversed listview
                      final message = messages[messages.length - 1 - index];
                      return MessageBubble(message: message);
                    },
                  ),
          ),
          ChatInput(
            onSend: _handleSend,
            onStop: () => ref.read(chatControllerProvider).stopGeneration(),
            isLoading: isGenerating,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: const Icon(Icons.smart_toy, size: 64, color: AppColors.accent),
          ),
          const SizedBox(height: 24),
          Text(
            'LocalLM',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'How can I help you today?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 32),
          
          // Quick actions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildQuickAction('Explain quantum computing', Icons.lightbulb_outline),
              _buildQuickAction('Write a Python script', Icons.code),
              _buildQuickAction('Summarize this text', Icons.article_outlined),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuickAction(String text, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.accentLight),
      label: Text(text, style: const TextStyle(fontSize: 13)),
      backgroundColor: AppColors.cardSurface,
      side: const BorderSide(color: AppColors.border),
      onPressed: () {
        _handleSend(text, null);
      },
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    final activeId = ref.watch(activeConversationIdProvider);

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.surface,
                ),
                onPressed: () {
                  ref.read(activeConversationIdProvider.notifier).state = null;
                  Navigator.pop(context); // Close drawer
                },
              ),
            ),
            const Divider(color: AppColors.border),
            Expanded(
              child: ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  final isActive = conv.id == activeId;
                  
                  return ListTile(
                    leading: const Icon(Icons.chat_bubble_outline, size: 20),
                    title: Text(
                      conv.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? AppColors.accent : AppColors.textPrimary,
                      ),
                    ),
                    selected: isActive,
                    selectedTileColor: AppColors.accent.withValues(alpha: 0.1),
                    onTap: () {
                      ref.read(activeConversationIdProvider.notifier).state = conv.id;
                      Navigator.pop(context);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () {
                        ref.read(conversationsProvider.notifier).deleteConversation(conv.id);
                        if (isActive) {
                          ref.read(activeConversationIdProvider.notifier).state = null;
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}
