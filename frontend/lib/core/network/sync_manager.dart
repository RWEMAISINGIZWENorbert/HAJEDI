import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hajedi/core/helpers/sync_queue.dart';
import 'package:hajedi/core/network/handlers/customer_sync_handler.dart';
import 'package:hajedi/core/network/handlers/supplier_sync_handler.dart';
import 'package:hajedi/core/network/handlers/expense_sync_handler.dart';
import 'package:hajedi/core/network/handlers/product_sync_handler.dart';
import 'package:hajedi/core/network/handlers/purchase_sync_handler.dart';
import 'package:hajedi/core/network/handlers/sale_sync_handler.dart';
import 'package:hajedi/core/network/handlers/user_sync_handler.dart';
import 'package:hajedi/core/network/sync_handler.dart';
import 'package:hajedi/data/customer.dart';
import 'package:hajedi/data/expense.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/data/purchase.dart';
import 'package:hajedi/data/sale.dart';
import 'package:hajedi/data/supplier.dart';
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/data/user.dart';
import 'package:hajedi/repository/customer_repository.dart';
import 'package:hajedi/repository/supplier_repository.dart';
import 'package:hajedi/repository/expense_repository.dart';
import 'package:hajedi/repository/product_repository.dart';
import 'package:hajedi/repository/purchase_repository.dart';
import 'package:hajedi/repository/sale_repository.dart';
import 'package:hajedi/repository/user_repository.dart';
import 'package:hive/hive.dart';

class SyncManager {
  final Box<SyncQueueItem> queueBox;
  final List<SyncHandler> handlers;

  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  late final Map<String, SyncHandler> _handlersByEntity;

  SyncManager({
    required this.queueBox,
    required this.handlers,
  }) {
    _handlersByEntity = {
      for (final handler in handlers) handler.entityType: handler,
    };
  }

  factory SyncManager.create({
    required Box<SyncQueueItem> queueBox,
    required Box<User> userBox,
    required Box<Product> productBox,
    required Box<Sale> saleBox,
    required Box<Purchase> purchaseBox,
    required Box<Expense> expenseBox,
    required Box<Customer> customerBox,
    required Box<Supplier> supplierBox,
  }) {
    final syncManager = SyncManager(
      queueBox: queueBox,
      handlers: [
        UserSyncHandler(
          userBox: userBox,
          userRepository: UserRepository(),
        ),
        ProductSyncHandler(
          productBox: productBox,
          productRepository: ProductRepository(),
        ),
        SaleSyncHandler(
          saleBox: saleBox,
          productBox: productBox,
          saleRepository: SaleRepository(),
        ),
        PurchaseSyncHandler(
          purchaseBox: purchaseBox,
          productBox: productBox,
          purchaseRepository: PurchaseRepository(),
        ),
        ExpenseSyncHandler(
          expenseBox: expenseBox,
          expenseRepository: ExpenseRepository(),
        ),
        CustomerSyncHandler(
          customerBox: customerBox,
          customerRepository: CustomerRepository(),
        ),
        SupplierSyncHandler(
          supplierBox: supplierBox,
          supplierRepository: SupplierRepository(),
        ),
      ],
    );

    // Set the syncManager reference for UserSyncHandler
    final userHandler = syncManager.handlers.first as UserSyncHandler;
    userHandler.syncManager = syncManager;

    return syncManager;
   

  }

  Future<void> start() async {
    final connectivity = Connectivity();

    _subscription = connectivity.onConnectivityChanged.listen(
      (results) async {
        if (!results.contains(ConnectivityResult.none)) {
          await syncIfConnected();
        }
      },
    );

    await syncIfConnected();
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> syncIfConnected() async {
    if (_isSyncing) {
      return;
    }

    final connectivity = Connectivity();
    final results = await connectivity.checkConnectivity();

    if (results.contains(ConnectivityResult.none)) {
      return;
    }

    _isSyncing = true;

    try {
      await _uploadPendingChanges();

      for (final handler in handlers) {
        await handler.pullRemoteChanges();
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _uploadPendingChanges() async {
    final pending = SyncQueue.getPending();

    for (final item in pending) {
      await SyncQueue.markSyncing(item.id);

      try {
        final success = await _sendToServer(item);

        if (success) {
          await SyncQueue.markSynced(item.id);
        } else {
          await SyncQueue.markFailed(
            item.id,
            error: 'Unsupported synchronization operation',
          );
        }
      } catch (error) {
        await SyncQueue.markFailed(
          item.id,
          error: error.toString(),
        );
      }
    }

    await SyncQueue.removeSynced();
  }

  Future<bool> _sendToServer(SyncQueueItem item) async {
    final handler = _handlersByEntity[item.entityType];

    if (handler == null) {
      return false;
    }

    return handler.sendToServer(item);
  }
}