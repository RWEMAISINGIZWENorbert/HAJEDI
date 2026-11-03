import 'package:hajedi/data/supplier.dart';

abstract class SupplierEvent {}

class LoadSuppliers extends SupplierEvent {}

class AddSupplierLocal extends SupplierEvent {
  final Supplier supplier;

  AddSupplierLocal(this.supplier);
}

class UpdateSupplierLocal extends SupplierEvent {
  final String clientId;
  final Supplier supplier;

  UpdateSupplierLocal(this.clientId, this.supplier);
}

class DeleteSupplierLocal extends SupplierEvent {
  final String clientId;

  DeleteSupplierLocal(this.clientId);
}

class SyncSuppliers extends SupplierEvent {}