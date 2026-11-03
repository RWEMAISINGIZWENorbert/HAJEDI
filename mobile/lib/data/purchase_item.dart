import 'package:hive/hive.dart';

part 'purchase_item.g.dart';

@HiveType(typeId: 32)
class PurchaseItem extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productClientId;

  @HiveField(2)
  final num quantity;

  @HiveField(3)
  final double purchaseCost;

  @HiveField(4)
  final double totalCost;

  PurchaseItem({
    required this.productId,
    required this.productClientId,
    required this.quantity,
    required this.purchaseCost,
    required this.totalCost,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      productId: json['productId']?.toString() ?? json['_id']?.toString() ?? '',
      productClientId: json['productClientId']?.toString() ?? '',
      quantity: json['quantity'] as num? ?? 0,
      purchaseCost: _toDouble(json['purchaseCost']),
      totalCost: _toDouble(json['totalCost']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productClientId': productClientId,
      'quantity': quantity,
      'purchaseCost': purchaseCost,
      'totalCost': totalCost,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
