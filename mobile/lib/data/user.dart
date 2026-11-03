import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String clientId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String role;

  @HiveField(4)
  String password;

  @HiveField(5)
  bool isSynced;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  User({
    required this.id,
    required this.clientId,
    required this.name,
    required this.role,
    required this.password,
    this.isSynced = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    final serverId = json['id'] ?? json['_id'] ?? '';
    final localClientId = json['clientId'] ?? serverId;

  return User(
    id: serverId.toString(),
    clientId: localClientId.toString(),
    name: json['name']?.toString() ?? '',
    role: json['role']?.toString() ?? 'employee',
    password: json['password']?.toString() ?? '',
    isSynced: json['isSynced'] as bool? ?? true,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'].toString()) ??
            DateTime.now()
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'].toString()) ??
            DateTime.now()
        : DateTime.now(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'name': name,
      'role': role,
      'password': password,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? clientId,
    String? name,
    String? role,
    String? password,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      role: role ?? this.role,
      password: password ?? this.password,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}