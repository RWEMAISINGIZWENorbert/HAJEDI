import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/purchase/purchase_bloc.dart';
import 'package:hajedi/bloc/purchase/purchase_event.dart';
import 'package:hajedi/bloc/purchase_cart/purchase_cart_bloc.dart';
import 'package:hajedi/bloc/purchase_cart/purchase_cart_event.dart';
import 'package:hajedi/bloc/purchase_cart/purchase_cart_state.dart';
import 'package:hajedi/data/cart_item.dart';
import 'package:hajedi/data/supplier.dart';
import 'package:hajedi/widgets/primary_button.dart';
import 'package:iconly/iconly.dart';
import 'package:hajedi/widgets/supplier/supplier_dropdown.dart';

Future<dynamic> showPurchaseCartBottomSheet(
  BuildContext context,
) {
  Supplier? selectedSupplier;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
          builder: (context, setState) {
      return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Theme.of(context).cardColor,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Purchase Cart',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(IconlyLight.close_square),
                    ),
                  ],
                ),
              ),
              const Divider(),

              Padding(
                padding: const EdgeInsets.all(8),
                child: SupplierDropdown(
                  selectedSupplier: selectedSupplier,
                  onSupplierChanged: (Supplier? supplier) {
                        setState(() {
                          selectedSupplier = supplier;
                        });
                    },
                ),
              ),
              const Divider(),

              // Cart Items List
              BlocBuilder<PurchaseCartBloc, PurchaseCartState>(
                builder: (context, state) {
                  if (state is PurchaseCartLoadedState) {
                    if (state.items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text('Cart is empty'),
                        ),
                      );
                    }

                    return Column(
                      children: state.items.map((item) {
                        return _PurchaseCartItemRow(
                          item: item,
                          onRemove: () {
                            context.read<PurchaseCartBloc>().add(
                              RemoveFromPurchaseCart(item.productClientId),
                            );
                          },
                          onIncrease: () {
                            context.read<PurchaseCartBloc>().add(
                              UpdatePurchaseCartQuantity(
                                item.productClientId,
                                item.quantity + 1,
                              ),
                            );
                          },
                          onDecrease: () {
                            context.read<PurchaseCartBloc>().add(
                              UpdatePurchaseCartQuantity(
                                item.productClientId,
                                item.quantity - 1,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Save Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<PurchaseCartBloc, PurchaseCartState>(
                  builder: (context, state) {
                    if (state is PurchaseCartLoadedState) {
                      return PrimaryButton(
                        label: 'Save Purchase',
                        onPressed: () {
                              
                              context.read<PurchaseBloc>().add(
                                CreatePurchaseLocal(
                                  cartItems: state.items,
                                  supplierClientId: selectedSupplier?.clientId, // Add supplier ID if you have supplier selection
                                  paymentMethod: 'cash', // or your preferred payment method
                               ),
                              );
                              context.read<PurchaseCartBloc>().add(ClearPurchaseCart());
                              Navigator.of(context).pop();
                           },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
          }
      );
    }
  );
}

class _PurchaseCartItemRow extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _PurchaseCartItemRow({
    required this.item,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Product Name and Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.unitPrice.toStringAsFixed(2)} frw',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),

          // Quantity Controls
          Row(
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Text(
                '${item.quantity}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onIncrease,
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Remove Button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
            iconSize: 20,
            color: Colors.red,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
