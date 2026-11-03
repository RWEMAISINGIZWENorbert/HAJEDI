
import 'package:hajedi/data/cart_item.dart';

abstract class CartEvent {}

class AddToCart extends CartEvent {
  final CartItem item;

  AddToCart(this.item);
}

class RemoveFromCart extends CartEvent {
  final String productClientId;

  RemoveFromCart(this.productClientId);
}

class UpdateCartQuantity extends CartEvent {
  final String productClientId;
  final int quantity;

  UpdateCartQuantity(this.productClientId, this.quantity);
}

class ClearCart extends CartEvent {}