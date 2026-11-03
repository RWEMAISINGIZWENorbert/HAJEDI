import 'package:hajedi/data/customer.dart';

abstract class CustomerEvent {}

class LoadCustomers extends CustomerEvent {}

class AddCustomerLocal extends CustomerEvent {
  final Customer customer;

  AddCustomerLocal(this.customer);
}

class UpdateCustomerLocal extends CustomerEvent {
  final String clientId;
  final Customer customer;

  UpdateCustomerLocal(this.clientId, this.customer);
}

class DeleteCustomerLocal extends CustomerEvent {
  final String clientId;

  DeleteCustomerLocal(this.clientId);
}

class SyncCustomers extends CustomerEvent {}