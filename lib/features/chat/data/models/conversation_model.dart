import 'package:hive/hive.dart';
import 'message_model.dart';

part 'conversation_model.g.dart';

@HiveType(typeId: 1)
class ConversationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  final List<MessageModel> messages;

  @HiveField(3)
  String? systemPromptId;

  @HiveField(4)
  String? modelId;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  ConversationModel({
    required this.id,
    required this.title,
    List<MessageModel>? messages,
    this.systemPromptId,
    this.modelId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ConversationModel copyWith({
    String? id,
    String? title,
    List<MessageModel>? messages,
    String? systemPromptId,
    String? modelId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      systemPromptId: systemPromptId ?? this.systemPromptId,
      modelId: modelId ?? this.modelId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
