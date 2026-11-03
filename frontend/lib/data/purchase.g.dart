// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseAdapter extends TypeAdapter<Purchase> {
  @override
  final int typeId = 33;

  @override
  Purchase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Purchase(
      id: fields[0] as String,
      clientId: fields[1] as String,
      userId: fields[2] as String,
      supplierId: fields[3] as String?,
      supplierClientId: fields[4] as String?,
      items: (fields[5] as List).cast<PurchaseItem>(),
      totalItems: fields[6] as num,
      totalCost: fields[7] as double,
      paymentMethod: fields[8] as String,
      syncStatus: fields[9] as String,
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
      voidedAt: fields[12] as DateTime?,
      failureReason: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Purchase obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.supplierId)
      ..writeByte(4)
      ..write(obj.supplierClientId)
      ..writeByte(5)
      ..write(obj.items)
      ..writeByte(6)
      ..write(obj.totalItems)
      ..writeByte(7)
      ..write(obj.totalCost)
      ..writeByte(8)
      ..write(obj.paymentMethod)
      ..writeByte(9)
      ..write(obj.syncStatus)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.voidedAt)
      ..writeByte(13)
      ..write(obj.failureReason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
