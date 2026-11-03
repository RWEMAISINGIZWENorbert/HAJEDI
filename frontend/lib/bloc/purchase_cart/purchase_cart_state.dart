import 'package:hajedi/data/cart_item.dart';

abstract class PurchaseCartState {}

class PurchaseCartLoadingState extends PurchaseCartState {}

class PurchaseCartLoadedState extends PurchaseCartState {
  final List<CartItem> items;
  final double totalAmount;

  PurchaseCartLoadedState(this.items) : totalAmount = items.fold(0, (sum, item) => sum + item.totalAmount);
}

class PurchaseCartErrorState extends PurchaseCartState {
  final String message;

  PurchaseCartErrorState(this.message);
}