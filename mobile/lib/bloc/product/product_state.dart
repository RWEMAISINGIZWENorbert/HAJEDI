part of 'product_bloc.dart';

@immutable
abstract class ProductState {}

class ProductInitial extends ProductState {}

class RegisterProductLoading extends ProductState {}

class ProductRegisteredSuccessfully extends ProductState {
  final String message;
  final Product product;

  ProductRegisteredSuccessfully({
    required this.message,
    required this.product,
  });
}

class RegisterProductFailure extends ProductState {
  final String message;

  RegisterProductFailure({
    required this.message,
  });
}

class ProductsLoading extends ProductState {}

class ProductsLoadedSuccessfully extends ProductState {
  final List<Product> products;

  ProductsLoadedSuccessfully({
    required this.products,
  });
}

class ProductsUpdatedSuccessfully extends ProductState {
  final String message;
  final Product product;

  ProductsUpdatedSuccessfully({
    required this.message,
    required this.product,
  });
}

class ProductUpdateFailure extends ProductState {
  final String message;

  ProductUpdateFailure({
    required this.message,
  });
}

class ProductsDeletedSuccessfully extends ProductState {
  final String message;
  final String clientId;

  ProductsDeletedSuccessfully({
    required this.message,
    required this.clientId,
  });
}

class ProductDeleteFailure extends ProductState {
  final String message;

  ProductDeleteFailure({
    required this.message,
  });
}

class ProductLoadFailure extends ProductState {
  final String message;

  ProductLoadFailure({
    required this.message,
  });
}