import 'dart:io';
import 'dart:convert';
import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 2)
class MessageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String role; // user, assistant, system

  @HiveField(2)
  String content;

  @HiveField(3)
  String? imagePath;

  @HiveField(4)
  int? tokenCount;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  bool isStreaming;

  @HiveField(7)
  List<Map<String, dynamic>>? toolCalls;

  @HiveField(8)
  String? toolCallId;

  MessageModel({
    required this.id,
    required this.role,
    required this.content,
    this.imagePath,
    this.tokenCount,
    this.toolCalls,
    this.toolCallId,
    DateTime? timestamp,
    this.isStreaming = false,
  }) : timestamp = timestamp ?? DateTime.now();

  MessageModel copyWith({
    String? id,
    String? role,
    String? content,
    String? imagePath,
    int? tokenCount,
    DateTime? timestamp,
    bool? isStreaming,
    List<Map<String, dynamic>>? toolCalls,
    String? toolCallId,
  }) {
    return MessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      tokenCount: tokenCount ?? this.tokenCount,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      toolCalls: toolCalls ?? this.toolCalls,
      toolCallId: toolCallId ?? this.toolCallId,
    );
  }

  Map<String, dynamic> toApiMessage() {
    if (role == 'tool') {
      return {
        'role': 'tool',
        'tool_call_id': toolCallId,
        'content': content,
      };
    }

    final Map<String, dynamic> msg = {'role': role};

    if (toolCalls != null && toolCalls!.isNotEmpty) {
      msg['tool_calls'] = toolCalls;
    }

    if (imagePath != null && imagePath!.isNotEmpty) {
      String base64Image = '';
      try {
        final bytes = File(imagePath!).readAsBytesSync();
        base64Image = base64Encode(bytes);
      } catch (e) {
        base64Image = '';
      }

      msg['content'] = [
        {'type': 'text', 'text': content},
        if (base64Image.isNotEmpty)
          {
            'type': 'image_url',
            'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
          },
      ];
    } else {
      msg['content'] = content;
    }

    return msg;
  }
}
