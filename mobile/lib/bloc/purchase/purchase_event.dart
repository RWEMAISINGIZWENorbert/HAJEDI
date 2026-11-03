
import 'package:hajedi/data/cart_item.dart';

abstract class PurchaseEvent {}

class LoadLocalPurchases extends PurchaseEvent {}

class CreatePurchaseLocal extends PurchaseEvent {
  final List<CartItem> cartItems;
  final String? supplierClientId;
  final String paymentMethod;

  CreatePurchaseLocal({
    required this.cartItems,
    this.supplierClientId,
    required this.paymentMethod,
  });
}

class RetryPurchaseSync extends PurchaseEvent {
  final String clientId;

  RetryPurchaseSync(this.clientId);
}
