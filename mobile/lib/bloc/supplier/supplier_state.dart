import 'package:hajedi/data/supplier.dart';

abstract class SupplierState {}

class SupplierInitial extends SupplierState {}

class SuppliersLoadingState extends SupplierState {}

class SuppliersLoadedState extends SupplierState {
  final List<Supplier> suppliers;

  SuppliersLoadedState({required this.suppliers});
}

class SupplierCreatingState extends SupplierState {}

class SupplierCreatedState extends SupplierState {
  final Supplier supplier;

  SupplierCreatedState({required this.supplier});
}

class SupplierUpdatingState extends SupplierState {}

class SupplierUpdatedState extends SupplierState {
  final Supplier supplier;

  SupplierUpdatedState({required this.supplier});
}

class SupplierDeletingState extends SupplierState {}

class SupplierDeletedState extends SupplierState {
  final String clientId;

  SupplierDeletedState({required this.clientId});
}

class RequestFailureState extends SupplierState {
  final String message;

  RequestFailureState({required this.message});
}