import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 34)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String clientId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final String paymentMethod;

  @HiveField(7)
  final String syncStatus;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  @HiveField(10)
  final DateTime? voidedAt;

  @HiveField(11)
  final String? failureReason;

  Expense({
    required this.id,
    required this.clientId,
    required this.userId,
    required this.description,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    this.syncStatus = 'pending',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.voidedAt,
    this.failureReason,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      category: json['category']?.toString() ?? 'other',
      paymentMethod: json['paymentMethod']?.toString() ?? 'cash',
      syncStatus: json['syncStatus']?.toString() ?? 'synced',
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
      voidedAt: json['voidedAt'] == null
          ? null
          : DateTime.tryParse(json['voidedAt'].toString()),
      failureReason: json['failureReason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'userId': userId,
      'description': description,
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'syncStatus': syncStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'voidedAt': voidedAt?.toIso8601String(),
      'failureReason': failureReason,
    };
  }

  Expense copyWith({
    String? id,
    String? clientId,
    String? userId,
    String? description,
    double? amount,
    String? category,
    String? paymentMethod,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? voidedAt,
    String? failureReason,
  }) {
    return Expense(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      voidedAt: voidedAt ?? this.voidedAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static DateTime _toDateTime(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }
}
