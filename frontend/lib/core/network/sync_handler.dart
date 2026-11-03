import 'package:hajedi/data/sync_queue_item.dart';

abstract interface class SyncHandler {
  String get entityType;

  Future<bool> sendToServer(SyncQueueItem item);

  Future<void> pullRemoteChanges();
}