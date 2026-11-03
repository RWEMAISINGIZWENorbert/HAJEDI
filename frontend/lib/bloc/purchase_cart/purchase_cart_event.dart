import 'package:hajedi/data/cart_item.dart';

abstract class PurchaseCartEvent {}

class AddToPurchaseCart extends PurchaseCartEvent {
  final CartItem item;

  AddToPurchaseCart(this.item);
}

class RemoveFromPurchaseCart extends PurchaseCartEvent {
  final String productClientId;

  RemoveFromPurchaseCart(this.productClientId);
}

class UpdatePurchaseCartQuantity extends PurchaseCartEvent {
  final String productClientId;
  final num quantity;

  UpdatePurchaseCartQuantity(this.productClientId, this.quantity);
}

class ClearPurchaseCart extends PurchaseCartEvent {}