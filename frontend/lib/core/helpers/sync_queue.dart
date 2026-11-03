import 'dart:convert';

import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class SyncQueue {
  static const String boxName = 'syncQueue';

  static Box<SyncQueueItem> get box => Hive.box<SyncQueueItem>(boxName);

  static Future<void> enqueue({
    required String entityType,
    required String operationType,
    required Map<String, dynamic> payload,
  }) async {
    final item = SyncQueueItem(
      id: const Uuid().v4(),
      entityType: entityType,
      operationType: operationType,
      payload: jsonEncode(payload),
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await box.add(item);
  }

  static List<SyncQueueItem> getPending() {
  final items = box.values
      .where(
        (item) =>
            item.status == 'pending' ||
            item.status == 'failed',
      )
      .toList();

  items.sort(
    (first, second) =>
        first.createdAt.compareTo(second.createdAt),
  );

  return items;
}

  static Future<void> markSyncing(String id) async {
    final index = box.values.toList().indexWhere((item) => item.id == id);
    if (index == -1) return;

    final current = box.getAt(index)!;
    await box.putAt(
      index,
      current.copyWith(
        status: 'syncing',
        updatedAt: DateTime.now(),
      ),
    );
  }

  static Future<void> markSynced(String id) async {
    final index = box.values.toList().indexWhere((item) => item.id == id);
    if (index == -1) return;

    final current = box.getAt(index)!;
    await box.putAt(
      index,
      current.copyWith(
        status: 'synced',
        updatedAt: DateTime.now(),
      ),
    );
  }

  static Future<void> markFailed(String id, {required String error}) async {
    final index = box.values.toList().indexWhere((item) => item.id == id);
    if (index == -1) return;

    final current = box.getAt(index)!;
    final retryCount = current.retryCount + 1;

    await box.putAt(
      index,
      current.copyWith(
        status: 'failed',
        retryCount: retryCount,
        updatedAt: DateTime.now(),
      ),
    );
  }

  static Future<void> removeSynced() async {
    final items = box.values.where((item) => item.status == 'synced').toList();

    for (final item in items) {
      await box.delete(item.key);
    }
  }
}