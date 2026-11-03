import 'package:hajedi/data/cart_item.dart';

abstract class CartState {}

class CartLoadingState extends CartState {}

class CartLoadedState extends CartState {
  final List<CartItem> items;
  final double totalAmount;

  CartLoadedState(this.items) : totalAmount = items.fold(0, (sum, item) => sum + item.totalAmount);
}

class CartErrorState extends CartState {
  final String message;

  CartErrorState(this.message);
}
