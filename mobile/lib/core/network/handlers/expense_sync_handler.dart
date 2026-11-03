import 'dart:convert';

import 'package:hajedi/core/network/sync_handler.dart';
import 'package:hajedi/core/network/sync_metadata.dart';
import 'package:hajedi/data/expense.dart';
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/repository/expense_repository.dart';
import 'package:hive/hive.dart';

class ExpenseSyncHandler implements SyncHandler {
  final Box<Expense> expenseBox;
  final ExpenseRepository expenseRepository;

  ExpenseSyncHandler({
    required this.expenseBox,
    required this.expenseRepository,
  });

  @override
  String get entityType => 'expense';

  @override
  Future<bool> sendToServer(SyncQueueItem item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;

    switch (item.operationType) {
      case 'create':
        return _createExpense(payload);
      default:
        return false;
    }
  }

  Future<bool> _createExpense(Map<String, dynamic> payload) async {
    final clientId = payload['clientId']?.toString();

    if (clientId == null) {
      return false;
    }

    try {
      final serverExpense = await expenseRepository.createExpense(
        clientId: clientId,
        description: payload['description']?.toString() ?? '',
        amount: _toDouble(payload['amount']),
        category: payload['category']?.toString() ?? 'other',
        paymentMethod: payload['paymentMethod']?.toString() ?? 'cash',
      );

      final storedExpense = expenseBox.get(clientId);

      if (storedExpense != null) {
        await expenseBox.put(
          clientId,
          storedExpense.copyWith(
            id: serverExpense.id,
            syncStatus: 'synced',
            updatedAt: DateTime.now(),
          ),
        );
      }

      return true;
    } catch (error) {
      final storedExpense = expenseBox.get(clientId);

      if (storedExpense != null) {
        await expenseBox.put(
          clientId,
          storedExpense.copyWith(
            syncStatus: 'rejected',
            failureReason: error.toString(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      return false;
    }
  }

  @override
  Future<void> pullRemoteChanges() async {
    final cursor = await SyncMetadata.getExpensesCursor();

    final response = await expenseRepository.getExpenseChanges(since: cursor);

    final data = response['data'] as Map<String, dynamic>;

    final created = data['created'] as List<dynamic>? ?? [];
    final updated = data['updated'] as List<dynamic>? ?? [];
    final voided = data['voided'] as List<dynamic>? ?? [];

    for (final item in created) {
      await _saveRemoteExpense(Map<String, dynamic>.from(item as Map));
    }

    for (final item in updated) {
      await _saveRemoteExpense(Map<String, dynamic>.from(item as Map));
    }

    for (final item in voided) {
      final voidedData = Map<String, dynamic>.from(item as Map);
      final clientId = voidedData['clientId']?.toString();

      if (clientId != null && clientId.isNotEmpty) {
        final expense = expenseBox.get(clientId);
        if (expense != null) {
          await expenseBox.put(
            clientId,
            expense.copyWith(
              voidedAt: DateTime.tryParse(voidedData['voidedAt'].toString()),
              updatedAt: DateTime.now(),
            ),
          );
        }
      }
    }

    final nextCursor = response['nextCursor']?.toString();

    if (nextCursor != null && nextCursor.isNotEmpty) {
      await SyncMetadata.saveExpensesCursor(nextCursor);
    }
  }

  Future<void> _saveRemoteExpense(Map<String, dynamic> data) async {
    final clientId = data['clientId']?.toString();

    if (clientId == null || clientId.isEmpty) {
      return;
    }

    final remoteExpense = Expense.fromJson(data);

    await expenseBox.put(
      clientId,
      remoteExpense.copyWith(syncStatus: 'synced'),
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
