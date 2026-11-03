import 'dart:convert';

import 'package:hajedi/core/network/sync_handler.dart';
import 'package:hajedi/core/network/sync_metadata.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/repository/product_repository.dart';
import 'package:hajedi/utils/auth_utils.dart';
import 'package:hive/hive.dart';

class ProductSyncHandler implements SyncHandler {
  final Box<Product> productBox;
  final ProductRepository productRepository;

  ProductSyncHandler({
    required this.productBox,
    required this.productRepository,
  });

  @override
  String get entityType => 'product';

  @override
  Future<bool> sendToServer(SyncQueueItem item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;

    switch (item.operationType) {
      case 'create':
        return _createProduct(payload);

      case 'update':
        return _updateProduct(payload);

      case 'delete':
        return _deleteProduct(payload);

      default:
        return false;
    }
  }

  Future<bool> _createProduct(
    Map<String, dynamic> payload,
  ) async {
    final clientId = _readClientId(payload);

    if (clientId == null) {
      return false;
    }

    final product = Product(
      id: payload['id']?.toString() ?? '',
      clientId: clientId,
      name: payload['name']?.toString() ?? '',
      productType: payload['productType']?.toString() ?? 'item',
      purchaseMethod: payload['purchaseMethod']?.toString() ?? 'unit',
      saleMethod: payload['saleMethod']?.toString() ?? 'unit',
      purchaseCost: _toDouble(payload['purchaseCost']),
      sellingPrice: _toDouble(payload['sellingPrice']),
      unitsPerPackage: _toInt(
        payload['unitsPerPackage'],
        fallback: 1,
      ),
      quantityInStock: _toInt(payload['quantityInStock']),
    );

    final serverProduct =
        await productRepository.registerProduct(product);

    final storedProduct = productBox.get(clientId);

    if (storedProduct != null) {
      await productBox.put(
        clientId,
        storedProduct.copyWith(
          id: serverProduct.id,
          clientId: serverProduct.clientId,
          isSynced: true,
          updatedAt: DateTime.now(),
        ),
      );
    }

    return true;
  }

  Future<bool> _updateProduct(
    Map<String, dynamic> payload,
  ) async {
    final clientId = _readClientId(payload);

    if (clientId == null) {
      return false;
    }

    await productRepository.updateProduct(
      clientId,
      name: payload['name']?.toString(),
      productType: payload['productType']?.toString(),
      purchaseMethod: payload['purchaseMethod']?.toString(),
      saleMethod: payload['saleMethod']?.toString(),
      purchaseCost: payload['purchaseCost'] == null
          ? null
          : _toDouble(payload['purchaseCost']),
      sellingPrice: payload['sellingPrice'] == null
          ? null
          : _toDouble(payload['sellingPrice']),
      unitsPerPackage: payload['unitsPerPackage'] == null
          ? null
          : _toInt(payload['unitsPerPackage']),
      quantityInStock: payload['quantityInStock'] == null
          ? null
          : _toInt(payload['quantityInStock']),
    );

    await _markLocalProductAsSynced(clientId);
    return true;
  }

  Future<bool> _deleteProduct(
    Map<String, dynamic> payload,
  ) async {
    final clientId = _readClientId(payload);

    if (clientId == null) {
      return false;
    }

    await productRepository.removeProduct(clientId);
    return true;
  }

  @override
  Future<void> pullRemoteChanges() async {
    final cursor = await SyncMetadata.getProductsCursor();
    
    final token = await AuthUtils.getToken();

    if(token == null || token.isEmpty) {
      return;
    }

    final response = await productRepository.getProductChanges(
      since: cursor,
    );

    final data = response['data'] as Map<String, dynamic>;

    final created = data['created'] as List<dynamic>? ?? [];
    final updated = data['updated'] as List<dynamic>? ?? [];
    final deleted = data['deleted'] as List<dynamic>? ?? [];

    for (final item in created) {
      await _saveRemoteProduct(
        Map<String, dynamic>.from(item as Map),
      );
    }

    for (final item in updated) {
      await _saveRemoteProduct(
        Map<String, dynamic>.from(item as Map),
      );
    }

    for (final item in deleted) {
      final deletedData = Map<String, dynamic>.from(item as Map);
      final clientId = deletedData['clientId']?.toString();

      if (clientId != null && clientId.isNotEmpty) {
        await productBox.delete(clientId);
      }
    }

    final nextCursor = response['nextCursor']?.toString();

    if (nextCursor != null && nextCursor.isNotEmpty) {
      await SyncMetadata.saveProductsCursor(nextCursor);
    }
  }

  Future<void> _saveRemoteProduct(
    Map<String, dynamic> data,
  ) async {
    final clientId = data['clientId']?.toString();

    if (clientId == null || clientId.isEmpty) {
      return;
    }

    final existingProduct = productBox.get(clientId);

    if (existingProduct != null && !existingProduct.isSynced) {
      return;
    }

    final remoteProduct = Product.fromJson(data);

    await productBox.put(
      clientId,
      remoteProduct.copyWith(
        isSynced: true,
      ),
    );
  }

  Future<void> _markLocalProductAsSynced(
    String clientId,
  ) async {
    final product = productBox.get(clientId);

    if (product == null) {
      return;
    }

    await productBox.put(
      clientId,
      product.copyWith(
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

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _toInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}