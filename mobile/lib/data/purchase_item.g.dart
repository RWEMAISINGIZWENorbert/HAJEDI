// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseItemAdapter extends TypeAdapter<PurchaseItem> {
  @override
  final int typeId = 32;

  @override
  PurchaseItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseItem(
      productId: fields[0] as String,
      productClientId: fields[1] as String,
      quantity: fields[2] as num,
      purchaseCost: fields[3] as double,
      totalCost: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productClientId)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.purchaseCost)
      ..writeByte(4)
      ..write(obj.totalCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
