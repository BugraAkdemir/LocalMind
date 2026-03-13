import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/models/message_model.dart';
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final VoidCallback? onRegenerate;
  final bool showRegenerate;

  const MessageBubble({
    super.key,
    required this.message,
    this.onRegenerate,
    this.showRegenerate = false,
  });

  bool get isUser => message.role == 'user';
  bool get isSystem => message.role == 'system';

  @override
  Widget build(BuildContext context) {
    if (isSystem) return const SizedBox.shrink(); // Hide system messages

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(context),
            const SizedBox(width: 12),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? AppColors.userBubble.withValues(alpha: 0.15) : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                  bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
                border: Border.all(
                  color: isUser ? AppColors.accent.withValues(alpha: 0.3) : AppColors.border,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imagePath != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.imagePath!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            color: AppColors.border,
                            child: const Center(child: Icon(Icons.broken_image)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  if (message.content.isEmpty && message.isStreaming)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 12, height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 8),
                        Text('Thinking...', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    )
                  else
                    MarkdownBody(
                      data: message.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isUser ? AppColors.textPrimary : AppColors.textSecondary,
                          height: 1.5,
                        ),
                        code: const TextStyle(
                          backgroundColor: Colors.transparent,
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                      builders: {
                        'code': CodeElementBuilder(),
                      },
                    ),
                    
                  if (message.isStreaming)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Icon(Icons.circle, size: 8, color: AppColors.accent),
                    ),
                    
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Timestamp (hidden for simplicity unless requested)
                      // Text(
                      //   intl.DateFormat('HH:mm').format(message.timestamp),
                      //   style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                      // ),
                      // const SizedBox(width: 12),
                      
                      if (!message.isStreaming) ...[
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: message.content));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard', style: TextStyle(fontSize: 12)), duration: Duration(seconds: 1)),
                            );
                          },
                          child: const Icon(Icons.copy, size: 14, color: AppColors.textMuted),
                        ),
                        if (!isUser && showRegenerate && onRegenerate != null) ...[
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: onRegenerate,
                            child: const Icon(Icons.refresh, size: 14, color: AppColors.textMuted),
                          ),
                        ],
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 12),
            _buildAvatar(context),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser ? AppColors.accent.withValues(alpha: 0.2) : AppColors.surfaceLight,
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 18,
        color: isUser ? AppColors.accent : AppColors.textPrimary,
      ),
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(element, TextStyle? preferredStyle) {
    if (!element.attributes.containsKey('class')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          element.textContent,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: AppColors.accentLight),
        ),
      );
    }

    // It's a code block with language
    final language = element.attributes['class']!.substring(9); // "language-dart" -> "dart"

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF282C34), // Atom One Dark bg
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF21252B),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () => Clipboard.setData(ClipboardData(text: element.textContent)),
                  child: const Icon(Icons.copy, size: 14, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: HighlightView(
                element.textContent,
                language: language,
                theme: atomOneDarkTheme,
                textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
