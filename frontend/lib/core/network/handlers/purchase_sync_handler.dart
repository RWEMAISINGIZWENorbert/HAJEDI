import 'dart:convert';

import 'package:hajedi/core/network/sync_handler.dart';
import 'package:hajedi/core/network/sync_metadata.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/data/purchase.dart';
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/repository/purchase_repository.dart';
import 'package:hive/hive.dart';

class PurchaseSyncHandler implements SyncHandler {
  final Box<Purchase> purchaseBox;
  final Box<Product> productBox;
  final PurchaseRepository purchaseRepository;

  PurchaseSyncHandler({
    required this.purchaseBox,
    required this.productBox,
    required this.purchaseRepository,
  });

  @override
  String get entityType => 'purchase';

  @override
  Future<bool> sendToServer(SyncQueueItem item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;

    switch (item.operationType) {
      case 'create':
        return _createPurchase(payload);
      default:
        return false;
    }
  }

  Future<bool> _createPurchase(Map<String, dynamic> payload) async {
    final clientId = payload['clientId']?.toString();

    if (clientId == null) {
      return false;
    }

    try {
      final items = (payload['items'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [];

      final serverPurchase = await purchaseRepository.createPurchase(
        clientId: clientId,
        supplierClientId: payload['supplierClientId']?.toString(),
        paymentMethod: payload['paymentMethod']?.toString() ?? 'cash',
        items: items,
      );

      final storedPurchase = purchaseBox.get(clientId);

      if (storedPurchase != null) {
        await purchaseBox.put(
          clientId,
          storedPurchase.copyWith(
            id: serverPurchase.id,
            syncStatus: 'synced',
            updatedAt: DateTime.now(),
          ),
        );
      }

      return true;
    } catch (error) {
      final storedPurchase = purchaseBox.get(clientId);

      if (storedPurchase != null) {
        await purchaseBox.put(
          clientId,
          storedPurchase.copyWith(
            syncStatus: 'rejected',
            failureReason: error.toString(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      final items = (payload['items'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [];
      await _restoreLocalStock(items);

      return false;
    }
  }

  Future<void> _restoreLocalStock(List<Map<String, dynamic>> items) async {
    for (final item in items) {
      final productClientId = item['productClientId']?.toString();
      final quantity = item['quantity'] as int? ?? 0;

      if (productClientId == null || quantity == 0) continue;

      final product = productBox.get(productClientId);

      if (product != null) {
        await productBox.put(
          productClientId,
          product.copyWith(
            quantityInStock: product.quantityInStock - quantity,
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
  }

  @override
  Future<void> pullRemoteChanges() async {
    final cursor = await SyncMetadata.getPurchasesCursor();

    final response = await purchaseRepository.getPurchaseChanges(since: cursor);

    final data = response['data'] as Map<String, dynamic>;

    final created = data['created'] as List<dynamic>? ?? [];
    final updated = data['updated'] as List<dynamic>? ?? [];
    final voided = data['voided'] as List<dynamic>? ?? [];

    for (final item in created) {
      await _saveRemotePurchase(Map<String, dynamic>.from(item as Map));
    }

    for (final item in updated) {
      await _saveRemotePurchase(Map<String, dynamic>.from(item as Map));
    }

    for (final item in voided) {
      final voidedData = Map<String, dynamic>.from(item as Map);
      final clientId = voidedData['clientId']?.toString();

      if (clientId != null && clientId.isNotEmpty) {
        final purchase = purchaseBox.get(clientId);
        if (purchase != null) {
          await purchaseBox.put(
            clientId,
            purchase.copyWith(
              voidedAt: DateTime.tryParse(voidedData['voidedAt'].toString()),
              updatedAt: DateTime.now(),
            ),
          );
        }
      }
    }

    final nextCursor = response['nextCursor']?.toString();

    if (nextCursor != null && nextCursor.isNotEmpty) {
      await SyncMetadata.savePurchasesCursor(nextCursor);
    }
  }

  Future<void> _saveRemotePurchase(Map<String, dynamic> data) async {
    final clientId = data['clientId']?.toString();

    if (clientId == null || clientId.isEmpty) {
      return;
    }

    final remotePurchase = Purchase.fromJson(data);

    await purchaseBox.put(
      clientId,
      remotePurchase.copyWith(syncStatus: 'synced'),
    );
  }
}
