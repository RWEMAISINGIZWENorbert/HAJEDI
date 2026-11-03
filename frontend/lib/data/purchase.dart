import 'package:hive/hive.dart';
import 'purchase_item.dart';

part 'purchase.g.dart';

@HiveType(typeId: 33)
class Purchase extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String clientId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String? supplierId;

  @HiveField(4)
  final String? supplierClientId;

  @HiveField(5)
  final List<PurchaseItem> items;

  @HiveField(6)
  final num totalItems;

  @HiveField(7)
  final double totalCost;

  @HiveField(8)
  final String paymentMethod;

  @HiveField(9)
  final String syncStatus;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  @HiveField(12)
  final DateTime? voidedAt;

  @HiveField(13)
  final String? failureReason;

  Purchase({
    required this.id,
    required this.clientId,
    required this.userId,
    this.supplierId,
    this.supplierClientId,
    required this.items,
    required this.totalItems,
    required this.totalCost,
    required this.paymentMethod,
    this.syncStatus = 'pending',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.voidedAt,
    this.failureReason,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Purchase.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((item) => PurchaseItem.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return Purchase(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      supplierId: json['supplierId']?.toString(),
      supplierClientId: json['supplierClientId']?.toString(),
      items: itemsList,
      totalItems: json['totalItems'] as num? ?? 0,
      totalCost: _toDouble(json['totalCost']),
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
      'supplierId': supplierId,
      'supplierClientId': supplierClientId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalItems': totalItems,
      'totalCost': totalCost,
      'paymentMethod': paymentMethod,
      'syncStatus': syncStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'voidedAt': voidedAt?.toIso8601String(),
      'failureReason': failureReason,
    };
  }

  Purchase copyWith({
    String? id,
    String? clientId,
    String? userId,
    String? supplierId,
    String? supplierClientId,
    List<PurchaseItem>? items,
    num? totalItems,
    double? totalCost,
    String? paymentMethod,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? voidedAt,
    String? failureReason,
  }) {
    return Purchase(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      userId: userId ?? this.userId,
      supplierId: supplierId ?? this.supplierId,
      supplierClientId: supplierClientId ?? this.supplierClientId,
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      totalCost: totalCost ?? this.totalCost,
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
