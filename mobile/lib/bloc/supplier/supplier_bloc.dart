import 'dart:async';

// import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/supplier/supplier_event.dart';
import 'package:hajedi/bloc/supplier/supplier_state.dart';
import 'package:hajedi/core/helpers/sync_queue.dart';
import 'package:hajedi/core/network/sync_manager.dart';
import 'package:hajedi/data/supplier.dart';
import 'package:hive/hive.dart';

// part 'supplier_event.dart';
// part 'supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final Box<Supplier> _supplierBox;
  final SyncManager _syncManager;

  StreamSubscription<BoxEvent>? _supplierBoxSubscription;

  SupplierBloc(
    this._supplierBox,
    this._syncManager,
  ) :
  super(SupplierInitial()) {
    on<LoadSuppliers>(_loadSuppliers);
    on<AddSupplierLocal>(_addSupplierLocal);
    on<UpdateSupplierLocal>(_updateSupplierLocal);
    on<DeleteSupplierLocal>(_deleteSupplierLocal);
    on<SyncSuppliers>(_syncSuppliers);

    _supplierBoxSubscription = _supplierBox.watch().listen((event) {
      add(LoadSuppliers());
    });
  }

  @override
  Future<void> close() async {
    await _supplierBoxSubscription?.cancel();
    return super.close();
  }

  Future<void> _loadSuppliers(
    LoadSuppliers event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SuppliersLoadingState());

    try {
      final suppliers = _supplierBox.values.toList();
      emit(SuppliersLoadedState(suppliers: suppliers));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _addSupplierLocal(
    AddSupplierLocal event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SuppliersLoadingState());

    try {
      final supplier = event.supplier.copyWith(
        isSynced: false,
        updatedAt: DateTime.now(),
      );

      final exists = _supplierBox.values.any(
        (storedSupplier) =>
            storedSupplier.clientId == supplier.clientId ||
            storedSupplier.phoneNumber.trim().toLowerCase() ==
                supplier.phoneNumber.trim().toLowerCase(),
      );

      if (!exists) {
        await _supplierBox.put(supplier.clientId, supplier);

        await SyncQueue.enqueue(
          entityType: 'supplier',
          operationType: 'create',
          payload: supplier.toJson(),
        );
      }
      
      await _syncManager.syncIfConnected();
      emit(SuppliersLoadedState(suppliers: _supplierBox.values.toList()));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _updateSupplierLocal(
    UpdateSupplierLocal event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SuppliersLoadingState());

    try {
      final existing = _supplierBox.get(event.clientId);

      if (existing == null) {
        throw Exception('Supplier not found locally');
      }

      final updated = event.supplier.copyWith(
        id: existing.id,
        clientId: existing.clientId,
        isSynced: false,
        updatedAt: DateTime.now(),
      );

      await _supplierBox.put(event.clientId, updated);

      await SyncQueue.enqueue(
        entityType: 'supplier',
        operationType: 'update',
        payload: updated.toJson(),
      );

      await _syncManager.syncIfConnected();
      emit(SuppliersLoadedState(suppliers: _supplierBox.values.toList()));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _deleteSupplierLocal(
    DeleteSupplierLocal event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SuppliersLoadingState());

    try {
      final supplier = _supplierBox.get(event.clientId);

      if (supplier != null) {
        await _supplierBox.delete(event.clientId);

        await SyncQueue.enqueue(
          entityType: 'supplier',
          operationType: 'delete',
          payload: {'id': supplier.id, 'clientId': event.clientId},
        );
      }
      
      await _syncManager.syncIfConnected();
      emit(SuppliersLoadedState(suppliers: _supplierBox.values.toList()));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _syncSuppliers(
    SyncSuppliers event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SuppliersLoadingState());

    try {
      final pendingSuppliers = _supplierBox.values.where((supplier) => !supplier.isSynced).toList();

      for (final supplier in pendingSuppliers) {
        final updated = supplier.copyWith(isSynced: true, updatedAt: DateTime.now());
        await _supplierBox.put(supplier.clientId, updated);
      }

      emit(SuppliersLoadedState(suppliers: _supplierBox.values.toList()));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }
}