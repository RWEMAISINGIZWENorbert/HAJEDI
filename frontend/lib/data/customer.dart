import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 35)
class Customer extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String clientId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String phoneNumber;

  @HiveField(4)
  final String? address;

  @HiveField(5)
  final double? creditLimit;

  @HiveField(6)
  final bool isSynced;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final DateTime? deletedAt;

  Customer({
    required this.id,
    required this.clientId,
    required this.name,
    required this.phoneNumber,
    this.address,
    this.creditLimit,
    this.isSynced = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Customer.fromJson(Map<String, dynamic> json) {
    final serverId = json['id'] ?? json['_id'] ?? '';
    final localClientId = json['clientId'] ?? serverId;

    return Customer(
      id: serverId.toString(),
      clientId: localClientId.toString(),
      name: json['name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? json['phoneNumber']?.toString() ?? '',
      address: json['address']?.toString(),
      creditLimit: _toDouble(json['creditLimit']),
      isSynced: json['isSynced'] as bool? ?? true,
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.tryParse(json['deletedAt'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'name': name,
      'phone_number': phoneNumber,
      'address': address,
      'creditLimit': creditLimit,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  Customer copyWith({
    String? id,
    String? clientId,
    String? name,
    String? phoneNumber,
    String? address,
    double? creditLimit,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      creditLimit: creditLimit ?? this.creditLimit,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _toDateTime(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.now();
  }
}