import 'dart:convert';

import 'package:hajedi/core/network/sync_handler.dart';
import 'package:hajedi/core/network/sync_metadata.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/data/sale.dart';
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/repository/sale_repository.dart';
import 'package:hive/hive.dart';

class SaleSyncHandler implements SyncHandler {
  final Box<Sale> saleBox;
  final Box<Product> productBox;
  final SaleRepository saleRepository;

  SaleSyncHandler({
    required this.saleBox,
    required this.productBox,
    required this.saleRepository,
  });

  @override
  String get entityType => 'sale';

  @override
  Future<bool> sendToServer(SyncQueueItem item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;

    switch (item.operationType) {
      case 'create':
        return _createSale(payload);
      case 'payCredit':
        return _payCredit(payload);
      default:
        return false;
    }
  }

  Future<bool> _createSale(Map<String, dynamic> payload) async {
    final clientId = payload['clientId']?.toString();

    if (clientId == null) {
      return false;
    }

    final items = (payload['items'] as List<dynamic>?)
            ?.map((item) => item as Map<String, dynamic>)
            .toList() ??
        [];

    try {
      final serverSale = await saleRepository.createSale(
        clientId: clientId,
        customerClientId: payload['customerClientId']?.toString(),
        paymentMethod: payload['paymentMethod']?.toString() ?? 'cash',
        items: items,
      );

      final storedSale = saleBox.get(clientId);

      if (storedSale != null) {
        await saleBox.put(
          clientId,
          storedSale.copyWith(
            id: serverSale.id,
            syncStatus: 'synced',
            updatedAt: DateTime.now(),
          ),
        );
      }

      return true;
    } catch (error) {
      // Mark sale as rejected
      final storedSale = saleBox.get(clientId);

      if (storedSale != null) {
        await saleBox.put(
          clientId,
          storedSale.copyWith(
            syncStatus: 'rejected',
            failureReason: error.toString(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      // Restore local stock
      await _restoreLocalStock(items);

      return false;
    }
  }

  Future<bool> _payCredit(Map<String, dynamic> payload) async {
    final clientId = payload['clientId']?.toString();
    final newPaymentMethod = payload['newPaymentMethod']?.toString();

    if (clientId == null || newPaymentMethod == null) {
      return false;
    }

    try {
      await saleRepository.payCreditSale(
        clientId: clientId,
        newPaymentMethod: newPaymentMethod,
      );

      final storedSale = saleBox.get(clientId);

      if (storedSale != null) {
        await saleBox.put(
          clientId,
          storedSale.copyWith(
            syncStatus: 'synced',
            updatedAt: DateTime.now(),
          ),
        );
      }

      return true;
    } catch (error) {
      // Mark sale as rejected
      final storedSale = saleBox.get(clientId);

      if (storedSale != null) {
        await saleBox.put(
          clientId,
          storedSale.copyWith(
            syncStatus: 'rejected',
            failureReason: error.toString(),
            updatedAt: DateTime.now(),
          ),
        );
      }

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
            quantityInStock: product.quantityInStock + quantity,
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
  }

  @override
  Future<void> pullRemoteChanges() async {
    final cursor = await SyncMetadata.getSalesCursor();

    final response = await saleRepository.getSaleChanges(since: cursor);

    final data = response['data'] as Map<String, dynamic>;

    final created = data['created'] as List<dynamic>? ?? [];
    final updated = data['updated'] as List<dynamic>? ?? [];
    final voided = data['voided'] as List<dynamic>? ?? [];

    for (final item in created) {
      await _saveRemoteSale(Map<String, dynamic>.from(item as Map));
    }

    for (final item in updated) {
      await _saveRemoteSale(Map<String, dynamic>.from(item as Map));
    }

    for (final item in voided) {
      final voidedData = Map<String, dynamic>.from(item as Map);
      final clientId = voidedData['clientId']?.toString();

      if (clientId != null && clientId.isNotEmpty) {
        final sale = saleBox.get(clientId);
        if (sale != null) {
          await saleBox.put(
            clientId,
            sale.copyWith(
              voidedAt: DateTime.tryParse(voidedData['voidedAt'].toString()),
              updatedAt: DateTime.now(),
            ),
          );
        }
      }
    }

    final nextCursor = response['nextCursor']?.toString();

    if (nextCursor != null && nextCursor.isNotEmpty) {
      await SyncMetadata.saveSalesCursor(nextCursor);
    }
  }

  Future<void> _saveRemoteSale(Map<String, dynamic> data) async {
    final clientId = data['clientId']?.toString();

    if (clientId == null || clientId.isEmpty) {
      return;
    }

    final remoteSale = Sale.fromJson(data);

    await saleBox.put(
      clientId,
      remoteSale.copyWith(syncStatus: 'synced'),
    );
  }
}