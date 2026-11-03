import 'dart:convert';

import 'package:hajedi/core/network/sync_handler.dart';
import 'package:hajedi/core/network/sync_metadata.dart';
import 'package:hajedi/data/supplier.dart';
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/repository/supplier_repository.dart';
import 'package:hive/hive.dart';

class SupplierSyncHandler implements SyncHandler {
  final Box<Supplier> supplierBox;
  final SupplierRepository supplierRepository;

  SupplierSyncHandler({
    required this.supplierBox,
    required this.supplierRepository,
  });

  @override
  String get entityType => 'supplier';

  @override
  Future<bool> sendToServer(SyncQueueItem item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;

    switch (item.operationType) {
      case 'create':
        return _createSupplier(payload);

      case 'update':
        return _updateSupplier(payload);

      case 'delete':
        return _deleteSupplier(payload);

      default:
        return false;
    }
  }

  Future<bool> _createSupplier(
    Map<String, dynamic> payload,
  ) async {
    final clientId = _readClientId(payload);

    if (clientId == null) {
      return false;
    }

    final supplier = Supplier(
      id: payload['id']?.toString() ?? '',
      clientId: clientId,
      name: payload['name']?.toString() ?? '',
      phoneNumber: payload['phone_number']?.toString() ?? payload['phoneNumber']?.toString() ?? '',
      address: payload['address']?.toString(),
    );

    final serverSupplier = await supplierRepository.createSupplier(supplier);
    final storedSupplier = supplierBox.get(clientId);

    if (storedSupplier != null) {
      await supplierBox.put(
        clientId,
        storedSupplier.copyWith(
          id: serverSupplier.id,
          clientId: serverSupplier.clientId,
          isSynced: true,
          updatedAt: DateTime.now(),
        ),
      );
    }

    return true;
  }

  Future<bool> _updateSupplier(
    Map<String, dynamic> payload,
  ) async {
    final clientId = _readClientId(payload);

    if (clientId == null) {
      return false;
    }

    await supplierRepository.updateSupplierByClientId(
      clientId,
      name: payload['name']?.toString(),
      phoneNumber: payload['phone_number']?.toString() ?? payload['phoneNumber']?.toString(),
      address: payload['address']?.toString(),
    );

    await _markLocalSupplierAsSynced(clientId);
    return true;
  }

  Future<bool> _deleteSupplier(
    Map<String, dynamic> payload,
  ) async {
    final clientId = _readClientId(payload);

    if (clientId == null) {
      return false;
    }

    await supplierRepository.deleteSupplierByClientId(clientId);
    return true;
  }

  @override
  Future<void> pullRemoteChanges() async {
    final cursor = await SyncMetadata.getSuppliersCursor();

    final response = await supplierRepository.getSupplierChanges(
      since: cursor,
    );

    final data = response['data'] as Map<String, dynamic>;

    final created = data['created'] as List<dynamic>? ?? [];
    final updated = data['updated'] as List<dynamic>? ?? [];
    final deleted = data['deleted'] as List<dynamic>? ?? [];

    for (final item in created) {
      await _saveRemoteSupplier(
        Map<String, dynamic>.from(item as Map),
      );
    }

    for (final item in updated) {
      await _saveRemoteSupplier(
        Map<String, dynamic>.from(item as Map),
      );
    }

    for (final item in deleted) {
      final deletedData = Map<String, dynamic>.from(item as Map);
      final clientId = deletedData['clientId']?.toString();

      if (clientId != null && clientId.isNotEmpty) {
        await supplierBox.delete(clientId);
      }
    }

    final nextCursor = response['nextCursor']?.toString();

    if (nextCursor != null && nextCursor.isNotEmpty) {
      await SyncMetadata.saveSuppliersCursor(nextCursor);
    }
  }

  Future<void> _saveRemoteSupplier(
    Map<String, dynamic> data,
  ) async {
    final clientId = data['clientId']?.toString();

    if (clientId == null || clientId.isEmpty) {
      return;
    }

    final existingSupplier = supplierBox.get(clientId);

    if (existingSupplier != null && !existingSupplier.isSynced) {
      return;
    }

    final remoteSupplier = Supplier.fromJson(data);

    await supplierBox.put(
      clientId,
      remoteSupplier.copyWith(
        isSynced: true,
      ),
    );
  }

  Future<void> _markLocalSupplierAsSynced(
    String clientId,
  ) async {
    final supplier = supplierBox.get(clientId);

    if (supplier == null) {
      return;
    }

    await supplierBox.put(
      clientId,
      supplier.copyWith(
        isSynced: true,
        updatedAt: DateTime.now(),
      ),
    );
  }

  String? _readClientId(
    Map<String, dynamic> payload,
  ) {
    final value = payload['clientId'] ?? payload['id'];
    final clientId = value?.toString();

    if (clientId == null || clientId.isEmpty) {
      return null;
    }

    return clientId;
  }
}