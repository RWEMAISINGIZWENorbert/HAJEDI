// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 1;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      clientId: fields[1] as String,
      name: fields[2] as String,
      productType: fields[3] as String,
      purchaseMethod: fields[4] as String,
      saleMethod: fields[5] as String,
      purchaseCost: fields[6] as double,
      sellingPrice: fields[7] as double,
      unitsPerPackage: fields[8] as int,
      quantityInStock: fields[9] as num,
      isSynced: fields[10] as bool,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
      deletedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.productType)
      ..writeByte(4)
      ..write(obj.purchaseMethod)
      ..writeByte(5)
      ..write(obj.saleMethod)
      ..writeByte(6)
      ..write(obj.purchaseCost)
      ..writeByte(7)
      ..write(obj.sellingPrice)
      ..writeByte(8)
      ..write(obj.unitsPerPackage)
      ..writeByte(9)
      ..write(obj.quantityInStock)
      ..writeByte(10)
      ..write(obj.isSynced)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
