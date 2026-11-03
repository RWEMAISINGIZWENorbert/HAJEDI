part of 'product_bloc.dart';

@immutable
abstract class ProductEvent {}

class LoadLocalProducts extends ProductEvent {}

class RegisterLocalProduct extends ProductEvent {
  final Product product;

  RegisterLocalProduct({
    required this.product,
  });
}

class UpdateLocalProduct extends ProductEvent {
  final String clientId;
  final Product product;

  UpdateLocalProduct({
    required this.clientId,
    required this.product,
  });
}

class DeleteLocalProduct extends ProductEvent {
  final String clientId;

  DeleteLocalProduct({
    required this.clientId,
  });
}