import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/cart/cart_event.dart';
import 'package:hajedi/bloc/cart/cart_state.dart';
import 'package:hajedi/data/cart_item.dart';

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartLoadedState([])) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
    on<ClearCart>(_onClearCart);
  }

  List<CartItem> _getItemsFromState() {
    if (state is CartLoadedState) {
      return (state as CartLoadedState).items;
    }
    return [];
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final items = _getItemsFromState();
    final existingIndex = items.indexWhere((item) => item.productClientId == event.item.productClientId);

    List<CartItem> updatedItems;
    if (existingIndex >= 0) {
      updatedItems = List.from(items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + event.item.quantity,
      );
    } else {
      updatedItems = [...items, event.item];
    }

    emit(CartLoadedState(updatedItems));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final items = _getItemsFromState();
    final updatedItems = items.where((item) => item.productClientId != event.productClientId).toList();
    emit(CartLoadedState(updatedItems));
  }

  void _onUpdateCartQuantity(UpdateCartQuantity event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      add(RemoveFromCart(event.productClientId));
      return;
    }

    final items = _getItemsFromState();
    final updatedItems = items.map((item) {
      if (item.productClientId == event.productClientId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();

    emit(CartLoadedState(updatedItems));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(CartLoadedState([]));
  }
}