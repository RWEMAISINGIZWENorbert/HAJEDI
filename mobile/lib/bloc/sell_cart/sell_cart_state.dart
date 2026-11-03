import 'package:hajedi/data/cart_item.dart';

abstract class SellCartState {}

class SellCartLoadingState extends SellCartState {}

class SellCartLoadedState extends SellCartState {
  final List<CartItem> items;
  final double totalAmount;

  SellCartLoadedState(this.items) : totalAmount = items.fold(0, (sum, item) => sum + item.totalAmount);
}

class SellCartErrorState extends SellCartState {
  final String message;

  SellCartErrorState(this.message);
}