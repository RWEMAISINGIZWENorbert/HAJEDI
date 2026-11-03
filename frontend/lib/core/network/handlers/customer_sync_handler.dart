import 'dart:convert';

import 'package:hajedi/core/network/sync_handler.dart';
import 'package:hajedi/core/network/sync_metadata.dart';
import 'package:hajedi/data/customer.dart';
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/repository/customer_repository.dart';
import 'package:hive/hive.dart';

class CustomerSyncHandler implements SyncHandler {
  final Box<Customer> customerBox;
  final CustomerRepository customerRepository;

  CustomerSyncHandler({
    required this.customerBox,
    required this.customerRepository,
  });

  @override
  String get entityType => 'customer';

  @override
  Future<bool> sendToServer(SyncQueueItem item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;

    switch (item.operationType) {
      case 'create':
        return _createCustomer(payload);

      case 'update':
        return _updateCustomer(payload);

      case 'delete':
        return _deleteCustomer(payload);

      default:
        return false;
    }
  }

  Future<bool> _createCustomer(
    Map<String, dynamic> payload,
  ) async {
    final clientId = _readClientId(payload);

    if (clientId == null) {
      return false;
    }

    final customer = Customer(
      id: payload['id']?.toString() ?? '',
      clientId: clientId,
      name: payload['name']?.toString() ?? '',
      phoneNumber: payload['phone_number']?.toString() ?? payload['phoneNumber']?.toString() ?? '',
      address: payload['address']?.toString(),
      creditLimit: _toDouble(payload['creditLimit']),
    );

    final serverCustomer = await customerRepository.createCustomer(customer);
    final storedCustomer = customerBox.get(clientId);

    if (storedCustomer != null) {
      await customerBox.put(
        clientId,
        storedCustomer.copyWith(
          id: serverCustomer.id,
          clientId: serverCustomer.clientId,
          isSynced: true,
          updatedAt: DateTime.now(),
        ),
      );
    }

    return true;
  }

  Future<bool> _updateCustomer(
    Map<String, dynamic> payload,
  ) async {
    final clientId = _readClientId(payload);

    if (clientId == null) {
      return false;
    }

    await customerRepository.updateCustomerByClientId(
      clientId,
      name: payload['name']?.toString(),
      phoneNumber: payload['phone_number']?.toString() ?? payload['phoneNumber']?.toString(),
      address: payload['address']?.toString(),
      creditLimit: payload['creditLimit'] == null
          ? null
          : _toDouble(payload['creditLimit']),
    );

    await _markLocalCustomerAsSynced(clientId);
    return true;
  }

  Future<bool> _deleteCustomer(
    Map<String, dynamic> payload,
  ) async {
    final clientId = _readClientId(payload);

    if (clientId == null) {
      return false;
    }

    await customerRepository.deleteCustomerByClientId(clientId);
    return true;
  }

  @override
  Future<void> pullRemoteChanges() async {
    final cursor = await SyncMetadata.getCustomersCursor();

    final response = await customerRepository.getCustomerChanges(
      since: cursor,
    );

    final data = response['data'] as Map<String, dynamic>;

    final created = data['created'] as List<dynamic>? ?? [];
    final updated = data['updated'] as List<dynamic>? ?? [];
    final deleted = data['deleted'] as List<dynamic>? ?? [];

    for (final item in created) {
      await _saveRemoteCustomer(
        Map<String, dynamic>.from(item as Map),
      );
    }

    for (final item in updated) {
      await _saveRemoteCustomer(
        Map<String, dynamic>.from(item as Map),
      );
    }

    for (final item in deleted) {
      final deletedData = Map<String, dynamic>.from(item as Map);
      final clientId = deletedData['clientId']?.toString();

      if (clientId != null && clientId.isNotEmpty) {
        await customerBox.delete(clientId);
      }
    }

    final nextCursor = response['nextCursor']?.toString();

    if (nextCursor != null && nextCursor.isNotEmpty) {
      await SyncMetadata.saveCustomersCursor(nextCursor);
    }
  }

  Future<void> _saveRemoteCustomer(
    Map<String, dynamic> data,
  ) async {
    final clientId = data['clientId']?.toString();

    if (clientId == null || clientId.isEmpty) {
      return;
    }

    final existingCustomer = customerBox.get(clientId);

    if (existingCustomer != null && !existingCustomer.isSynced) {
      return;
    }

    final remoteCustomer = Customer.fromJson(data);

    await customerBox.put(
      clientId,
      remoteCustomer.copyWith(
        isSynced: true,
      ),
    );
  }

  Future<void> _markLocalCustomerAsSynced(
    String clientId,
  ) async {
    final customer = customerBox.get(clientId);

    if (customer == null) {
      return;
    }

    await customerBox.put(
      clientId,
      customer.copyWith(
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
}