
import 'package:hajedi/data/purchase.dart';

abstract class PurchaseState {}

class PurchasesLoadingState extends PurchaseState {}

class PurchasesLoadedState extends PurchaseState {
  final List<Purchase> purchases;

  PurchasesLoadedState(this.purchases);
}

class PurchaseCreatingState extends PurchaseState {}

class PurchaseCreatedState extends PurchaseState {
  final Purchase purchase;

  PurchaseCreatedState(this.purchase);
}

class PurchaseErrorState extends PurchaseState {
  final String message;

  PurchaseErrorState(this.message);
}