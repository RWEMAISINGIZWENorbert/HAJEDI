import 'package:hajedi/data/cart_item.dart';

abstract class SaleEvent {}

class LoadLocalSales extends SaleEvent {}

class LoadCreditSales extends SaleEvent {}

class CreateSaleLocal extends SaleEvent {
  final List<CartItem> cartItems;
  final String? customerClientId;
  final String paymentMethod;

  CreateSaleLocal({
    required this.cartItems,
    this.customerClientId,
    required this.paymentMethod,
  });
}

class RetrySaleSync extends SaleEvent {
  final String clientId;

  RetrySaleSync(this.clientId);
}

class PayCreditSaleLocal extends SaleEvent {
  final String clientId;
  final String newPaymentMethod;

  PayCreditSaleLocal({
    required this.clientId,
    required this.newPaymentMethod,
  });
}