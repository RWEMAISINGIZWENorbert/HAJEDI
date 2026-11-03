import 'dart:async';

// import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/customer/customer_event.dart';
import 'package:hajedi/bloc/customer/customer_state.dart';
import 'package:hajedi/core/helpers/sync_queue.dart';
import 'package:hajedi/core/network/sync_manager.dart';
import 'package:hajedi/data/customer.dart';
import 'package:hive/hive.dart';

// part 'customer_event.dart';
// part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final Box<Customer> _customerBox;
  final SyncManager _syncManager;

  StreamSubscription<BoxEvent>? _customerBoxSubscription;

  CustomerBloc(
    this._customerBox,
    this._syncManager,
  ) : 
   super(CustomerInitial()) {
    on<LoadCustomers>(_loadCustomers);
    on<AddCustomerLocal>(_addCustomerLocal);
    on<UpdateCustomerLocal>(_updateCustomerLocal);
    on<DeleteCustomerLocal>(_deleteCustomerLocal);
    on<SyncCustomers>(_syncCustomers);

    _customerBoxSubscription = _customerBox.watch().listen((event) {
      add(LoadCustomers());
    });
  }

  @override
  Future<void> close() async {
    await _customerBoxSubscription?.cancel();
    return super.close();
  }

  Future<void> _loadCustomers(
    LoadCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomersLoadingState());

    try {
      final customers = _customerBox.values.toList();
      emit(CustomersLoadedState(customers: customers));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _addCustomerLocal(
    AddCustomerLocal event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomersLoadingState());

    try {
      final customer = event.customer.copyWith(
        isSynced: false,
        updatedAt: DateTime.now(),
      );

      final exists = _customerBox.values.any(
        (storedCustomer) =>
            storedCustomer.clientId == customer.clientId ||
            storedCustomer.phoneNumber.trim().toLowerCase() ==
                customer.phoneNumber.trim().toLowerCase(),
      );

      if (!exists) {
        await _customerBox.put(customer.clientId, customer);

        await SyncQueue.enqueue(
          entityType: 'customer',
          operationType: 'create',
          payload: customer.toJson(),
        );
      }
      
      await _syncManager.syncIfConnected();
      emit(CustomersLoadedState(customers: _customerBox.values.toList()));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _updateCustomerLocal(
    UpdateCustomerLocal event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomersLoadingState());

    try {
      final existing = _customerBox.get(event.clientId);

      if (existing == null) {
        throw Exception('Customer not found locally');
      }

      final updated = event.customer.copyWith(
        id: existing.id,
        clientId: existing.clientId,
        isSynced: false,
        updatedAt: DateTime.now(),
      );

      await _customerBox.put(event.clientId, updated);

      await SyncQueue.enqueue(
        entityType: 'customer',
        operationType: 'update',
        payload: updated.toJson(),
      );

      await _syncManager.syncIfConnected();
      emit(CustomersLoadedState(customers: _customerBox.values.toList()));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _deleteCustomerLocal(
    DeleteCustomerLocal event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomersLoadingState());

    try {
      final customer = _customerBox.get(event.clientId);

      if (customer != null) {
        await _customerBox.delete(event.clientId);

        await SyncQueue.enqueue(
          entityType: 'customer',
          operationType: 'delete',
          payload: {'id': customer.id, 'clientId': event.clientId},
        );
      }
      
      await _syncManager.syncIfConnected();
      emit(CustomersLoadedState(customers: _customerBox.values.toList()));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _syncCustomers(
    SyncCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomersLoadingState());

    try {
      final pendingCustomers = _customerBox.values.where((customer) => !customer.isSynced).toList();

      for (final customer in pendingCustomers) {
        final updated = customer.copyWith(isSynced: true, updatedAt: DateTime.now());
        await _customerBox.put(customer.clientId, updated);
      }

      emit(CustomersLoadedState(customers: _customerBox.values.toList()));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }
}