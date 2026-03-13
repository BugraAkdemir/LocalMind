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

  MessageModel({
    required this.id,
    required this.role,
    required this.content,
    this.imagePath,
    this.tokenCount,
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
  }) {
    return MessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      tokenCount: tokenCount ?? this.tokenCount,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  Map<String, dynamic> toApiMessage() {
    if (imagePath != null && imagePath!.isNotEmpty) {
      String base64Image = '';
      try {
        final bytes = File(imagePath!).readAsBytesSync();
        base64Image = base64Encode(bytes);
      } catch (e) {
        // Fallback or handle error. For now, we'll just try to pass the path
        base64Image = '';
      }

      return {
        'role': role,
        'content': [
          {'type': 'text', 'text': content},
          if (base64Image.isNotEmpty)
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
            },
        ],
      };
    }
    return {'role': role, 'content': content};
  }
}
