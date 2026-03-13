import 'package:hive/hive.dart';

part 'system_prompt_model.g.dart';

@HiveType(typeId: 3)
class SystemPromptModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String content;

  @HiveField(3)
  bool isDefault;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  SystemPromptModel({
    required this.id,
    required this.name,
    required this.content,
    this.isDefault = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  SystemPromptModel copyWith({
    String? id,
    String? name,
    String? content,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SystemPromptModel(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
