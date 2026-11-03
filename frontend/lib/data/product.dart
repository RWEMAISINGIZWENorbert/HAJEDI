import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 1)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String clientId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String productType;

  @HiveField(4)
  String purchaseMethod;

  @HiveField(5)
  String saleMethod;

  @HiveField(6)
  double purchaseCost;

  @HiveField(7)
  double sellingPrice;

  @HiveField(8)
  int unitsPerPackage;

  @HiveField(9)
  num quantityInStock;

  @HiveField(10)
  bool isSynced;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime updatedAt;

  @HiveField(13)
  DateTime? deletedAt;

  Product({
    required this.id,
    required this.clientId,
    required this.name,
    required this.productType,
    required this.purchaseMethod,
    required this.saleMethod,
    required this.purchaseCost,
    required this.sellingPrice,
    required this.unitsPerPackage,
    required this.quantityInStock,
    this.isSynced = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Product.fromJson(Map<String, dynamic> json) {
    final serverId = json['id'] ?? json['_id'] ?? '';
    final localClientId = json['clientId'] ?? serverId;

    return Product(
      id: serverId.toString(),
      clientId: localClientId.toString(),
      name: json['name']?.toString() ?? '',
      productType: json['productType']?.toString() ?? 'item',
      purchaseMethod: json['purchaseMethod']?.toString() ?? 'unit',
      saleMethod: json['saleMethod']?.toString() ?? 'unit',
      purchaseCost: _toDouble(json['purchaseCost']),
      sellingPrice: _toDouble(json['sellingPrice']),
      unitsPerPackage: _toInt(json['unitsPerPackage'], fallback: 1),
      // quantityInStock: _toInt(json['quantityInStock']),
      quantityInStock: json['quantityInStock'],
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
      'productType': productType,
      'purchaseMethod': purchaseMethod,
      'saleMethod': saleMethod,
      'purchaseCost': purchaseCost,
      'sellingPrice': sellingPrice,
      'unitsPerPackage': unitsPerPackage,
      'quantityInStock': quantityInStock,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? clientId,
    String? name,
    String? productType,
    String? purchaseMethod,
    String? saleMethod,
    double? purchaseCost,
    double? sellingPrice,
    int? unitsPerPackage,
    num? quantityInStock,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Product(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      productType: productType ?? this.productType,
      purchaseMethod: purchaseMethod ?? this.purchaseMethod,
      saleMethod: saleMethod ?? this.saleMethod,
      purchaseCost: purchaseCost ?? this.purchaseCost,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      unitsPerPackage: unitsPerPackage ?? this.unitsPerPackage,
      quantityInStock: quantityInStock ?? this.quantityInStock,
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

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static DateTime _toDateTime(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.now();
  }
}