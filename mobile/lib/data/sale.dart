import 'package:hive/hive.dart';
import 'sale_item.dart';

part 'sale.g.dart';

@HiveType(typeId: 31)
class Sale extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String clientId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final List<SaleItem> items;

  @HiveField(4)
  final num totalItems;

  @HiveField(5)
  final double totalAmount;

  @HiveField(6)
  final String? customerId;

  @HiveField(7)
  final String? customerClientId;

  @HiveField(8)
  final String paymentMethod;

  @HiveField(9)
  final String originalPaymentMethod;

  @HiveField(10)
  final String syncStatus;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  @HiveField(13)
  final DateTime? voidedAt;

  @HiveField(14)
  final String? failureReason;

  Sale({
    required this.id,
    required this.clientId,
    required this.userId,
    required this.items,
    required this.totalItems,
    required this.totalAmount,
    this.customerId,
    this.customerClientId,
    required this.paymentMethod,
    required this.originalPaymentMethod,
    this.syncStatus = 'pending',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.voidedAt,
    this.failureReason,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Sale.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((item) => SaleItem.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return Sale(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      items: itemsList,
      totalItems: json['totalItems'] as num? ?? 0,
      totalAmount: _toDouble(json['totalAmount']),
      customerId: json['customerId']?.toString(),
      customerClientId: json['customerClientId']?.toString(),
      paymentMethod: json['paymentMethod']?.toString() ?? 'cash',
      originalPaymentMethod: json['originalPaymentMethod']?.toString() ?? 'cash',
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
      'items': items.map((item) => item.toJson()).toList(),
      'totalItems': totalItems,
      'totalAmount': totalAmount,
      'customerId': customerId,
      'customerClientId': customerClientId,
      'paymentMethod': paymentMethod,
      'originalPaymentMethod': originalPaymentMethod,
      'syncStatus': syncStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'voidedAt': voidedAt?.toIso8601String(),
      'failureReason': failureReason,
    };
  }

  Sale copyWith({
    String? id,
    String? clientId,
    String? userId,
    List<SaleItem>? items,
    int? totalItems,
    double? totalAmount,
    String? customerId,
    String? customerClientId,
    String? paymentMethod,
    String? originalPaymentMethod,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? voidedAt,
    String? failureReason,
  }) {
    return Sale(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      totalAmount: totalAmount ?? this.totalAmount,
      customerId: customerId ?? this.customerId,
      customerClientId: customerClientId ?? this.customerClientId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      originalPaymentMethod: originalPaymentMethod ?? this.originalPaymentMethod,
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
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return DateTime.now();
     // Convert UTC to local time
     return parsed.toLocal();
  }
}
