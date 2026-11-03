import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/sale/sale_event.dart';
import 'package:hajedi/bloc/sale/sale_state.dart';
import 'package:hajedi/core/helpers/sync_queue.dart';
import 'package:hajedi/core/network/sync_manager.dart';
import 'package:hajedi/data/cart_item.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/data/sale.dart';
import 'package:hajedi/data/sale_item.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';


class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final Box<Sale> _saleBox;
  final Box<Product> _productBox;
  final SyncManager _syncManager;
  final Uuid _uuid = Uuid();

  SaleBloc({
    required Box<Sale> saleBox,
    required Box<Product> productBox,
    required SyncManager syncManager,
  })  : _saleBox = saleBox,
        _productBox = productBox,
        _syncManager = syncManager,
        super(SalesLoadingState()) {
    on<LoadLocalSales>(_onLoadLocalSales);
    on<CreateSaleLocal>(_onCreateSaleLocal);
    on<RetrySaleSync>(_onRetrySaleSync);
    on<PayCreditSaleLocal>(_onPayCreditSaleLocal);
    on<LoadCreditSales>(_onLoadCreditSales);

    _saleBox.watch().listen((_) {
      add(LoadLocalSales());
    });

    add(LoadLocalSales());
  }

  Future<void> _onLoadLocalSales(LoadLocalSales event, Emitter<SaleState> emit) async {
    final sales = _saleBox.values.toList();
    emit(SalesLoadedState(sales));
  }

  Future<void> _onLoadCreditSales(
  LoadCreditSales event,
  Emitter<SaleState> emit,
) async {
  final creditSales = _saleBox.values
      .where((sale) => sale.paymentMethod == 'credit')
      .toList();
  emit(SalesLoadedState(creditSales));
}

  Future<void> _onCreateSaleLocal(CreateSaleLocal event, Emitter<SaleState> emit) async {
    emit(SaleCreatingState());

    try {
      final clientId = _uuid.v4();
      final userId = 'current_user_id'; // Get from auth

      final saleItems = event.cartItems.map((cartItem) {
        final product = _productBox.get(cartItem.productClientId);
        return SaleItem(
          productId: product?.id ?? '',
          productClientId: cartItem.productClientId,
          quantity: cartItem.quantity,
          price: cartItem.unitPrice,
          totalAmount: cartItem.totalAmount,
        );
      }).toList();

      final totalItems = saleItems.fold(0.0, (sum, item) => sum + item.quantity);
      final totalAmount = saleItems.fold(0.0, (sum, item) => sum + item.totalAmount);

      final sale = Sale(
        id: '',
        clientId: clientId,
        userId: userId,
        items: saleItems,
        totalItems: totalItems,
        totalAmount: totalAmount,
        customerClientId: event.customerClientId,
        paymentMethod: event.paymentMethod,
        originalPaymentMethod: event.paymentMethod,
        syncStatus: 'pending',
      );

      await _saleBox.put(clientId, sale);

      // Project local stock decrement
      await _projectLocalStockDecrement(event.cartItems);

      // Enqueue for sync
      await SyncQueue.enqueue(
        entityType: 'sale',
        operationType: 'create',
        payload: sale.toJson(),
      );

      emit(SaleCreatedState(sale));
      await _syncManager.syncIfConnected();
      add(LoadLocalSales());
    } catch (error) {
      emit(SaleErrorState(error.toString()));
    }
  }

  Future<void> _onPayCreditSaleLocal(
  PayCreditSaleLocal event,
  Emitter<SaleState> emit,
) async {
  try {
    final sale = _saleBox.get(event.clientId);
    
    if (sale == null) {
      emit(SaleErrorState('Sale not found'));
      return;
    }

    // Update sale locally
    final updatedSale = sale.copyWith(
      paymentMethod: event.newPaymentMethod,
      updatedAt: DateTime.now(),
    );

    await _saleBox.put(event.clientId, updatedSale);

    // Enqueue for sync
    await SyncQueue.enqueue(
      entityType: 'sale',
      operationType: 'payCredit',
      payload: {
        'clientId': event.clientId,
        'newPaymentMethod': event.newPaymentMethod,
      },
    );

    emit(SalesLoadedState(_saleBox.values.toList()));
    await _syncManager.syncIfConnected();
  } catch (error) {
    emit(SaleErrorState(error.toString()));
  }
}

  Future<void> _projectLocalStockDecrement(List<CartItem> cartItems) async {
    for (final item in cartItems) {
      final product = _productBox.get(item.productClientId);
      if (product != null) {
        await _productBox.put(
          item.productClientId,
          product.copyWith(
            quantityInStock: product.quantityInStock - item.quantity,
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
  }

  Future<void> _onRetrySaleSync(RetrySaleSync event, Emitter<SaleState> emit) async {
    final sale = _saleBox.get(event.clientId);
    if (sale != null && sale.syncStatus == 'rejected') {
      await _saleBox.put(
        event.clientId,
        sale.copyWith(
          syncStatus: 'pending',
          failureReason: null,
          updatedAt: DateTime.now(),
        ),
      );

      await SyncQueue.enqueue(
        entityType: 'sale',
        operationType: 'create',
        payload: sale.toJson(),
      );

      await _syncManager.syncIfConnected();
    }
  }
}