import 'package:hajedi/data/customer.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomersLoadingState extends CustomerState {}

class CustomersLoadedState extends CustomerState {
  final List<Customer> customers;

  CustomersLoadedState({required this.customers});
}

class CustomerCreatingState extends CustomerState {}

class CustomerCreatedState extends CustomerState {
  final Customer customer;

  CustomerCreatedState({required this.customer});
}

class CustomerUpdatingState extends CustomerState {}

class CustomerUpdatedState extends CustomerState {
  final Customer customer;

  CustomerUpdatedState({required this.customer});
}

class CustomerDeletingState extends CustomerState {}

class CustomerDeletedState extends CustomerState {
  final String clientId;

  CustomerDeletedState({required this.clientId});
}

class RequestFailureState extends CustomerState {
  final String message;

  RequestFailureState({required this.message});
}