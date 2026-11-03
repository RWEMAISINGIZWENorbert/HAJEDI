import 'package:hive/hive.dart';

part 'sync_queue_item.g.dart';

@HiveType(typeId: 20)
class SyncQueueItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String entityType;

  @HiveField(2)
  final String operationType;

  @HiveField(3)
  final String payload;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final int retryCount;

  SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.operationType,
    required this.payload,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.retryCount = 0,
  });

  SyncQueueItem copyWith({
    String? id,
    String? entityType,
    String? operationType,
    String? payload,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? retryCount,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      operationType: operationType ?? this.operationType,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}