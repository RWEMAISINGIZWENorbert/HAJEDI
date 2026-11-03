import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:hajedi/core/helpers/sync_queue.dart';
import 'package:hajedi/core/network/sync_manager.dart';
import 'package:hajedi/data/product.dart';
import 'package:hive/hive.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final Box<Product> _productBox;
  final SyncManager _syncManager;

  StreamSubscription<BoxEvent>? _productBoxSubscription;

  ProductBloc(
    this._productBox,
    this._syncManager,
  ) : super(ProductInitial()) {
    on<LoadLocalProducts>(_loadLocalProducts);
    on<RegisterLocalProduct>(_registerLocalProduct);
    on<UpdateLocalProduct>(_updateLocalProduct);
    on<DeleteLocalProduct>(_deleteLocalProduct);

    _productBoxSubscription = _productBox.watch().listen((_) {
      add(LoadLocalProducts());
    });
  }

  Future<void> _loadLocalProducts(
    LoadLocalProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductsLoading());

    try {
      final products = _productBox.values.toList();

      emit(
        ProductsLoadedSuccessfully(
          products: products,
        ),
      );
    } catch (error) {
      emit(
        ProductLoadFailure(
          message: _errorMessage(error),
        ),
      );
    }
  }

  Future<void> _registerLocalProduct(
    RegisterLocalProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(RegisterProductLoading());

    try {
      final product = event.product.copyWith(
        isSynced: false,
        updatedAt: DateTime.now(),
      );

      final alreadyExists = _productBox.values.any(
        (storedProduct) =>
            storedProduct.clientId == product.clientId ||
            storedProduct.name.trim().toLowerCase() ==
                product.name.trim().toLowerCase(),
      );

      if (alreadyExists) {
        emit(
          RegisterProductFailure(
            message: 'Product already exists',
          ),
        );
        return;
      }

      await _productBox.put(
        product.clientId,
        product,
      );

      await SyncQueue.enqueue(
        entityType: 'product',
        operationType: 'create',
        payload: product.toJson(),
      );

      emit(
        ProductRegisteredSuccessfully(
          message: 'Product registered successfully',
          product: product,
        ),
      );

      await _syncManager.syncIfConnected();
    } catch (error) {
      emit(
        RegisterProductFailure(
          message: _errorMessage(error),
        ),
      );
    }
  }

  Future<void> _updateLocalProduct(
    UpdateLocalProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductsLoading());
      final existingProduct = _productBox.get(event.clientId);

      if (existingProduct == null) {
        emit(
          ProductUpdateFailure(
            message: 'Product not found locally',
          ),
        );
        return;
      }

      final updatedProduct = event.product.copyWith(
        id: existingProduct.id,
        clientId: existingProduct.clientId,
        isSynced: false,
        updatedAt: DateTime.now(),
      );

      await _productBox.put(
        existingProduct.clientId,
        updatedProduct,
      );

      await SyncQueue.enqueue(
        entityType: 'product',
        operationType: 'update',
        payload: updatedProduct.toJson(),
      );

      emit(
        ProductsUpdatedSuccessfully(
          message: 'Product updated successfully',
          product: updatedProduct,
        ),
      );

      await _syncManager.syncIfConnected();
      emit(
  ProductsLoadedSuccessfully(
    products: _productBox.values.toList(),
  ),
);
    } catch (error) {
      emit(
        ProductUpdateFailure(
          message: _errorMessage(error),
        ),
      );
    }
  }

  Future<void> _deleteLocalProduct(
    DeleteLocalProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final product = _productBox.get(event.clientId);

      if (product == null) {
        emit(
          ProductDeleteFailure(
            message: 'Product not found locally',
          ),
        );
        return;
      }

      await _productBox.delete(product.clientId);

      await SyncQueue.enqueue(
        entityType: 'product',
        operationType: 'delete',
        payload: {
          'id': product.id,
          'clientId': product.clientId,
        },
      );

      emit(
        ProductsDeletedSuccessfully(
          message: 'Product deleted successfully',
          clientId: product.clientId,
        ),
      );

      await _syncManager.syncIfConnected();
      emit(
  ProductsLoadedSuccessfully(
    products: _productBox.values.toList(),
  ),
);
    } catch (error) {
      emit(
        ProductDeleteFailure(
          message: _errorMessage(error),
        ),
      );
    }
  }

  String _errorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Future<void> close() async {
    await _productBoxSubscription?.cancel();
    return super.close();
  }
}