class CartItem {
  final String productClientId;
  final String productName;
  final num quantity;
  final double unitPrice;

  const CartItem({
    required this.productClientId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalAmount => quantity * unitPrice;

  CartItem copyWith({
    String? productClientId,
    String? productName,
    num? quantity,
    double? unitPrice,
  }) {
    return CartItem(
      productClientId: productClientId ?? this.productClientId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productClientId': productClientId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productClientId: json['productClientId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      quantity: json['quantity'] as num? ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
