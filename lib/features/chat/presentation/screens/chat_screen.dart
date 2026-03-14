import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../../../server/presentation/providers/server_provider.dart';
import '../../../../core/widgets/connection_indicator.dart';
import 'package:mobile_locallm/core/localization/app_i18n.dart';

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

  Future<void> _handleSend(String text, String? imagePath) async {
    try {
      await ref.read(chatControllerProvider).sendMessage(text, imagePath: imagePath);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppI18n.of(context);
      final msg = e.toString();
      final friendly = msg.contains(ChatController.errNoActiveServer) ? l10n.noServerConnected : msg;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            friendly,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppI18n.of(context);
    final activeConversation = ref.watch(activeConversationProvider);
    final activeServer = ref.watch(activeServerProvider);
    final serverConn = ref.watch(activeServerConnectionProvider);
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    
    // Determine if we are currently waiting for a stream based on the last message
    final messages = activeConversation?.messages ?? [];
    final isGenerating = messages.isNotEmpty && messages.last.isStreaming;

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: _ConversationsDrawer(
        onNewChat: () => ref.read(activeConversationIdProvider.notifier).state = null,
      ),
      appBar: AppBar(
        titleSpacing: 16,
        title: _Header(
          title: activeConversation?.title ?? 'New Chat',
          serverName: activeServer?.name,
          isConnected: serverConn.valueOrNull?.isConnected ?? false,
          isConnecting: serverConn.isLoading ||
              (serverConn.valueOrNull?.isConnecting ?? false),
        ),
        actions: [
          IconButton(
            tooltip: l10n.controlCenter,
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showControlCenter(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(context, keyboardOpen: keyboardOpen)
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.only(bottom: 16, top: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
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

  Widget _buildEmptyState(BuildContext context, {required bool keyboardOpen}) {
    final l10n = AppI18n.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + (keyboardOpen ? 24 : 64),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface.withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.smart_toy,
                      size: keyboardOpen ? 44 : 56,
                      color: AppColors.accentLight,
                    ),
                  ),
                  SizedBox(height: keyboardOpen ? 14 : 18),
                  Text(
                    l10n.appName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    keyboardOpen
                        ? l10n.typeToStart
                        : l10n.welcomeTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  if (!keyboardOpen) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline, size: 16, color: AppColors.textMuted),
                          SizedBox(width: 8),
                          Text(
                            l10n.noCloudStoredOnDevice,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showConversationsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardSurface,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Consumer(
            builder: (context, ref, _) {
              final l10n = AppI18n.of(context);
              final conversations = ref.watch(conversationsProvider);
              final activeId = ref.watch(activeConversationIdProvider);

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.conversations,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            ref
                                .read(activeConversationIdProvider.notifier)
                                .state = null;
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.add),
                          label: Text(l10n.newChatShort),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (conversations.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            l10n.noConversationsYet,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: conversations.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final conv = conversations[i];
                            final isActive = conv.id == activeId;
                            return ListTile(
                              leading: Icon(
                                isActive
                                    ? Icons.chat_bubble
                                    : Icons.chat_bubble_outline,
                                color: isActive
                                    ? AppColors.accent
                                    : AppColors.textMuted,
                              ),
                              title: Text(
                                conv.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isActive
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              subtitle: Text(
                                l10n.messagesCount(conv.messages.length),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  ref
                                      .read(conversationsProvider.notifier)
                                      .deleteConversation(conv.id);
                                  if (isActive) {
                                    ref
                                        .read(activeConversationIdProvider
                                            .notifier)
                                        .state = null;
                                  }
                                },
                              ),
                              onTap: () {
                                ref
                                    .read(activeConversationIdProvider.notifier)
                                    .state = conv.id;
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showControlCenter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardSurface,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final l10n = AppI18n.of(context);
              // Bound height so the sheet never overflows; content becomes scrollable.
              final maxH = constraints.maxHeight * 0.92;
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.view_list_rounded),
                      title: Text(l10n.conversations),
                      subtitle: Text(l10n.conversationsSubtitle),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showConversationsSheet(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.add_rounded),
                      title: Text(l10n.newChat),
                      onTap: () {
                        ref.read(activeConversationIdProvider.notifier).state = null;
                        Navigator.pop(ctx);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.dns_outlined),
                      title: Text(l10n.servers),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/servers');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.memory_outlined),
                      title: Text(l10n.models),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/models');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: Text(l10n.settings),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/settings');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.terminal_rounded),
                      title: Text(l10n.systemPrompts),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/prompts');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: Text(l10n.clearMessages),
                      textColor: Colors.redAccent,
                      iconColor: Colors.redAccent,
                      onTap: () async {
                        Navigator.pop(ctx);
                        final activeConversation = ref.read(activeConversationProvider);
                        if (activeConversation == null || activeConversation.messages.isEmpty) {
                          return;
                        }
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.cardSurface,
                            title: Text(l10n.clearChatHistoryTitle),
                            content: Text(l10n.clearChatHistoryBody),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  l10n.cancel,
                                  style: const TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  l10n.clear,
                                  style: const TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          ref.read(chatControllerProvider).clearCurrentConversation();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? serverName;
  final bool isConnected;
  final bool isConnecting;

  const _Header({
    required this.title,
    required this.serverName,
    required this.isConnected,
    required this.isConnecting,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppI18n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            ConnectionIndicator(
              isConnected: isConnected,
              isConnecting: isConnecting,
              size: 6,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                serverName ?? l10n.noServerSelected,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConversationsDrawer extends ConsumerWidget {
  final VoidCallback onNewChat;

  const _ConversationsDrawer({required this.onNewChat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppI18n.of(context);
    final conversations = ref.watch(conversationsProvider);
    final activeId = ref.watch(activeConversationIdProvider);

    return Drawer(
      backgroundColor: AppColors.cardSurface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.conversations,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.close,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                onPressed: () {
                  onNewChat();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.newChat),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Expanded(
              child: conversations.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          l10n.noConversationsYet,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: conversations.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final conv = conversations[i];
                        final isActive = conv.id == activeId;
                        return ListTile(
                          leading: Icon(
                            isActive
                                ? Icons.chat_bubble_rounded
                                : Icons.chat_bubble_outline_rounded,
                            color: isActive ? AppColors.accent : AppColors.textMuted,
                          ),
                          title: Text(
                            conv.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            l10n.messagesCount(conv.messages.length),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: l10n.delete,
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: () {
                              ref
                                  .read(conversationsProvider.notifier)
                                  .deleteConversation(conv.id);
                              if (isActive) {
                                ref.read(activeConversationIdProvider.notifier).state = null;
                              }
                            },
                          ),
                          onTap: () {
                            ref.read(activeConversationIdProvider.notifier).state = conv.id;
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.settings),
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
