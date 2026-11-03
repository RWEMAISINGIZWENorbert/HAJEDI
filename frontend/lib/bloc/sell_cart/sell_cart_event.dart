import 'package:hajedi/data/cart_item.dart';

abstract class SellCartEvent {}

class AddToSellCart extends SellCartEvent {
  final CartItem item;

  AddToSellCart(this.item);
}

class RemoveFromSellCart extends SellCartEvent {
  final String productClientId;

  RemoveFromSellCart(this.productClientId);
}

class UpdateSellCartQuantity extends SellCartEvent {
  final String productClientId;
  final num quantity;

  UpdateSellCartQuantity(this.productClientId, this.quantity);
}

class ClearSellCart extends SellCartEvent {}