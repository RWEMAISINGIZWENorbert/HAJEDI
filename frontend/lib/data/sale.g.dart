// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleAdapter extends TypeAdapter<Sale> {
  @override
  final int typeId = 31;

  @override
  Sale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sale(
      id: fields[0] as String,
      clientId: fields[1] as String,
      userId: fields[2] as String,
      items: (fields[3] as List).cast<SaleItem>(),
      totalItems: fields[4] as num,
      totalAmount: fields[5] as double,
      customerId: fields[6] as String?,
      customerClientId: fields[7] as String?,
      paymentMethod: fields[8] as String,
      originalPaymentMethod: fields[9] as String,
      syncStatus: fields[10] as String,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
      voidedAt: fields[13] as DateTime?,
      failureReason: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Sale obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.totalItems)
      ..writeByte(5)
      ..write(obj.totalAmount)
      ..writeByte(6)
      ..write(obj.customerId)
      ..writeByte(7)
      ..write(obj.customerClientId)
      ..writeByte(8)
      ..write(obj.paymentMethod)
      ..writeByte(9)
      ..write(obj.originalPaymentMethod)
      ..writeByte(10)
      ..write(obj.syncStatus)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.voidedAt)
      ..writeByte(14)
      ..write(obj.failureReason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
