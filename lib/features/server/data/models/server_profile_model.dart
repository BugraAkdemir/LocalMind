import 'package:hive/hive.dart';

part 'server_profile_model.g.dart';

@HiveType(typeId: 0)
class ServerProfileModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String host;

  @HiveField(3)
  int port;

  @HiveField(4)
  bool isDefault;

  @HiveField(5)
  DateTime? lastConnected;

  @HiveField(6)
  bool isActive;

  ServerProfileModel({
    required this.id,
    required this.name,
    required this.host,
    this.port = 1234,
    this.isDefault = false,
    this.lastConnected,
    this.isActive = false,
  });

  ServerProfileModel copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    bool? isDefault,
    DateTime? lastConnected,
    bool? isActive,
  }) {
    return ServerProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      isDefault: isDefault ?? this.isDefault,
      lastConnected: lastConnected ?? this.lastConnected,
      isActive: isActive ?? this.isActive,
    );
  }

  String get baseUrl => 'http://$host:$port';
}
