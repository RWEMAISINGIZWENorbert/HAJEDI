import 'package:hajedi/data/sale.dart';

abstract class SaleState {}

class SalesLoadingState extends SaleState {}

class SalesLoadedState extends SaleState {
  final List<Sale> sales;

  SalesLoadedState(this.sales);
}

class SaleCreatingState extends SaleState {}

class SaleCreatedState extends SaleState {
  final Sale sale;

  SaleCreatedState(this.sale);
}

class SaleErrorState extends SaleState {
  final String message;

  SaleErrorState(this.message);
}
