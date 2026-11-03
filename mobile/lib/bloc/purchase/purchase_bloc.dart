import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/purchase/purchase_event.dart';
import 'package:hajedi/bloc/purchase/purchase_state.dart';
import 'package:hajedi/core/helpers/sync_queue.dart';
import 'package:hajedi/core/network/sync_manager.dart';
import 'package:hajedi/data/cart_item.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/data/purchase.dart';
import 'package:hajedi/data/purchase_item.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';


// Bloc
class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final Box<Purchase> _purchaseBox;
  final Box<Product> _productBox;
  final SyncManager _syncManager;
  final Uuid _uuid = Uuid();

  PurchaseBloc({
    required Box<Purchase> purchaseBox,
    required Box<Product> productBox,
    required SyncManager syncManager,
  })  : _purchaseBox = purchaseBox,
        _productBox = productBox,
        _syncManager = syncManager,
        super(PurchasesLoadingState()) {
    on<LoadLocalPurchases>(_onLoadLocalPurchases);
    on<CreatePurchaseLocal>(_onCreatePurchaseLocal);
    on<RetryPurchaseSync>(_onRetryPurchaseSync);

    _purchaseBox.watch().listen((_) {
      add(LoadLocalPurchases());
    });

    add(LoadLocalPurchases());
  }

  Future<void> _onLoadLocalPurchases(LoadLocalPurchases event, Emitter<PurchaseState> emit) async {
    final purchases = _purchaseBox.values.toList();
    emit(PurchasesLoadedState(purchases));
  }

  Future<void> _onCreatePurchaseLocal(CreatePurchaseLocal event, Emitter<PurchaseState> emit) async {
  emit(PurchaseCreatingState());

  try {
    final clientId = _uuid.v4();
    final userId = 'current_user_id'; // Get from auth

    // Create modified cart items with adjusted quantities
    final modifiedCartItems = event.cartItems.map((cartItem) {
      final product = _productBox.get(cartItem.productClientId);
      if((product?.purchaseMethod == "packet") || (product?.purchaseMethod == "crate") || (product?.purchaseMethod == "sack")){
        final adjustedQuantity = cartItem.quantity * product!.unitsPerPackage;
        return cartItem.copyWith(quantity: adjustedQuantity);
      }
      return cartItem;
    }).toList();

    final purchaseItems = event.cartItems.map((cartItem) {
      final product = _productBox.get(cartItem.productClientId);
      return PurchaseItem(
        productId: product?.id ?? '',
        productClientId: cartItem.productClientId,
        quantity: cartItem.quantity,
        purchaseCost: product?.purchaseCost ?? 0.0,
        totalCost: cartItem.totalAmount,
      );
    }).toList();

    final totalItems = purchaseItems.fold(0.0, (sum, item) => sum + item.quantity);
    final totalCost = purchaseItems.fold(0.0, (sum, item) => sum + item.totalCost);

    final purchase = Purchase(
      id: '',
      clientId: clientId,
      userId: userId,
      supplierClientId: event.supplierClientId,
      items: purchaseItems,
      totalItems: totalItems,
      totalCost: totalCost,
      paymentMethod: event.paymentMethod,
      syncStatus: 'pending',
    );

    await _purchaseBox.put(clientId, purchase);

    // Project local stock increment with modified quantities
    await _projectLocalStockIncrement(modifiedCartItems);

    // Enqueue for sync
    await SyncQueue.enqueue(
      entityType: 'purchase',
      operationType: 'create',
      payload: purchase.toJson(),
    );

    emit(PurchaseCreatedState(purchase));
    await _syncManager.syncIfConnected();
    add(LoadLocalPurchases());
  } catch (error) {
    emit(PurchaseErrorState(error.toString()));
  }
}

  Future<void> _projectLocalStockIncrement(List<CartItem> cartItems) async {
    for (final item in cartItems) {
      final product = _productBox.get(item.productClientId);
      if (product != null) {
        await _productBox.put(
          item.productClientId,
          product.copyWith(
            quantityInStock: product.quantityInStock + item.quantity,
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
  }

  Future<void> _onRetryPurchaseSync(RetryPurchaseSync event, Emitter<PurchaseState> emit) async {
    final purchase = _purchaseBox.get(event.clientId);
    if (purchase != null && purchase.syncStatus == 'rejected') {
      await _purchaseBox.put(
        event.clientId,
        purchase.copyWith(
          syncStatus: 'pending',
          failureReason: null,
          updatedAt: DateTime.now(),
        ),
      );

      await SyncQueue.enqueue(
        entityType: 'purchase',
        operationType: 'create',
        payload: purchase.toJson(),
      );

      await _syncManager.syncIfConnected();
    }
  }
}