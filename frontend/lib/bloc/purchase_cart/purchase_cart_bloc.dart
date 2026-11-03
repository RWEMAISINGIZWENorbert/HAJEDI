import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/purchase_cart/purchase_cart_event.dart';
import 'package:hajedi/bloc/purchase_cart/purchase_cart_state.dart';
import 'package:hajedi/data/cart_item.dart';

class PurchaseCartBloc extends Bloc<PurchaseCartEvent, PurchaseCartState> {
  PurchaseCartBloc() : super(PurchaseCartLoadedState([])) {
    on<AddToPurchaseCart>(_onAddToPurchaseCart);
    on<RemoveFromPurchaseCart>(_onRemoveFromPurchaseCart);
    on<UpdatePurchaseCartQuantity>(_onUpdatePurchaseCartQuantity);
    on<ClearPurchaseCart>(_onClearPurchaseCart);
  }

  List<CartItem> _getItemsFromState() {
    if (state is PurchaseCartLoadedState) {
      return (state as PurchaseCartLoadedState).items;
    }
    return [];
  }

  void _onAddToPurchaseCart(AddToPurchaseCart event, Emitter<PurchaseCartState> emit) {
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

    emit(PurchaseCartLoadedState(updatedItems));
  }

  void _onRemoveFromPurchaseCart(RemoveFromPurchaseCart event, Emitter<PurchaseCartState> emit) {
    final items = _getItemsFromState();
    final updatedItems = items.where((item) => item.productClientId != event.productClientId).toList();
    emit(PurchaseCartLoadedState(updatedItems));
  }

  void _onUpdatePurchaseCartQuantity(UpdatePurchaseCartQuantity event, Emitter<PurchaseCartState> emit) {
    if (event.quantity <= 0) {
      add(RemoveFromPurchaseCart(event.productClientId));
      return;
    }

    final items = _getItemsFromState();
    final updatedItems = items.map((item) {
      if (item.productClientId == event.productClientId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();

    emit(PurchaseCartLoadedState(updatedItems));
  }

  void _onClearPurchaseCart(ClearPurchaseCart event, Emitter<PurchaseCartState> emit) {
    emit(PurchaseCartLoadedState([]));
  }
}