import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/sell_cart/sell_cart_event.dart';
import 'package:hajedi/bloc/sell_cart/sell_cart_state.dart';
import 'package:hajedi/data/cart_item.dart';

class SellCartBloc extends Bloc<SellCartEvent, SellCartState> {
  SellCartBloc() : super(SellCartLoadedState([])) {
    on<AddToSellCart>(_onAddToSellCart);
    on<RemoveFromSellCart>(_onRemoveFromSellCart);
    on<UpdateSellCartQuantity>(_onUpdateSellCartQuantity);
    on<ClearSellCart>(_onClearSellCart);
  }

  List<CartItem> _getItemsFromState() {
    if (state is SellCartLoadedState) {
      return (state as SellCartLoadedState).items;
    }
    return [];
  }

  void _onAddToSellCart(AddToSellCart event, Emitter<SellCartState> emit) {
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

    emit(SellCartLoadedState(updatedItems));
  }

  void _onRemoveFromSellCart(RemoveFromSellCart event, Emitter<SellCartState> emit) {
    final items = _getItemsFromState();
    final updatedItems = items.where((item) => item.productClientId != event.productClientId).toList();
    emit(SellCartLoadedState(updatedItems));
  }

  void _onUpdateSellCartQuantity(UpdateSellCartQuantity event, Emitter<SellCartState> emit) {
    if (event.quantity <= 0) {
      add(RemoveFromSellCart(event.productClientId));
      return;
    }

    final items = _getItemsFromState();
    final updatedItems = items.map((item) {
      if (item.productClientId == event.productClientId) {
        return item.copyWith(quantity: event.quantity.toDouble());
      }
      return item;
    }).toList();

    emit(SellCartLoadedState(updatedItems));
  }

  void _onClearSellCart(ClearSellCart event, Emitter<SellCartState> emit) {
    emit(SellCartLoadedState([]));
  }
}