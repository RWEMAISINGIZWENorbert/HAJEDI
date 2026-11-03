import 'package:hive/hive.dart';

part 'sale_item.g.dart';

@HiveType(typeId: 30)
class SaleItem extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productClientId;

  @HiveField(2)
  final num quantity;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final double totalAmount;

  SaleItem({
    required this.productId,
    required this.productClientId,
    required this.quantity,
    required this.price,
    required this.totalAmount,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['productId']?.toString() ?? json['_id']?.toString() ?? '',
      productClientId: json['productClientId']?.toString() ?? '',
      quantity: json['quantity'] as num? ?? 0,
      price: _toDouble(json['price']),
      totalAmount: _toDouble(json['totalAmount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productClientId': productClientId,
      'quantity': quantity,
      'price': price,
      'totalAmount': totalAmount,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
