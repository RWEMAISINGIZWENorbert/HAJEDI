import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/sell_cart/sell_cart_bloc.dart';
import 'package:hajedi/bloc/sell_cart/sell_cart_event.dart';
import 'package:hajedi/bloc/sell_cart/sell_cart_state.dart';
import 'package:hajedi/bloc/sale/sale_bloc.dart';
import 'package:hajedi/bloc/sale/sale_event.dart';
import 'package:hajedi/data/cart_item.dart';
import 'package:hajedi/data/customer.dart';
import 'package:hajedi/widgets/customer/customer_dropdown.dart';
import 'package:hajedi/widgets/primary_button.dart';
import 'package:iconly/iconly.dart';
import 'package:hajedi/l10n/app_localizations.dart';

Future<dynamic> showSellCartBottomSheet(
  BuildContext context,
) {
  Customer? selectedCustomer;
  String? selectedPayment;
  final loc = AppLocalizations.of(context)!;

  final List<Map<String, dynamic>> paymentMethods = [
    {'label': loc.cash, 'value': 'cash', 'icon': Icons.attach_money},
    {'label': loc.mobile, 'value': 'mobile', 'icon': Icons.phone_android},
    {'label': loc.credit, 'value': 'credit', 'icon': Icons.account_balance},
  ];

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
                      'Sell Cart',
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

              // Payment Method Selection
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: paymentMethods.map((method) {
                            final isSelected =
                                selectedPayment == method['value'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedPayment = method['value'];
                                });
                              },
                              child: Card(
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.2)
                                    : Colors.white,
                                elevation: isSelected ? 4 : 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: SizedBox(
                                  width: 60,
                                  height: 40,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(method['icon'],
                                          size: 16,
                                          color: isSelected
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.grey),
                                      const SizedBox(height: 2),
                                      // Text(method['label'], style: TextStyle(
                                      //   color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                                      //   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      // )),
                                      Text(method['label'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),   
                      const Divider(),
                      
                      // Customer Selection
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: CustomerDropdown(
                          selectedCustomer: selectedCustomer,
                          onCustomerChanged: (Customer? customer) {
                            setState(() {
                              selectedCustomer = customer;
                            });
                          },
                        ),
                      ),

                      const Divider(),

              // Cart Items List
              BlocBuilder<SellCartBloc, SellCartState>(
                builder: (context, state) {
                  if (state is SellCartLoadedState) {
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
                        return _CartItemRow(
                          item: item,
                          onRemove: () {
                            context.read<SellCartBloc>().add(
                              RemoveFromSellCart(item.productClientId),
                            );
                          },
                          onIncrease: () {
                            context.read<SellCartBloc>().add(
                              UpdateSellCartQuantity(
                                item.productClientId,
                                item.quantity + 1,
                              ),
                            );
                          },
                          onDecrease: () {
                            context.read<SellCartBloc>().add(
                              UpdateSellCartQuantity(
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
                child: BlocBuilder<SellCartBloc, SellCartState>(
                  builder: (context, state) {
                    if (state is SellCartLoadedState) {
                      return PrimaryButton(
                        label: 'Save',
                        onPressed:
                             () {
                              if (selectedPayment == null) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title:  Text("payment method required"),
                                content:  Text("choose payment method"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: Text("ok", style: const TextStyle(color: Colors.green),),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }
                          // if (selectedPayment == 'credit' &&
                          //     selectedCustomer == null) {
                          if (selectedPayment == 'credit') {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                // title: const Text('Custometr Required'),
                                title: Text("select_customer"),
                                content: const Text('You have to choose the customer for the credit.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child:  Text("ok"),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }
                              context.read<SaleBloc>().add(
                                CreateSaleLocal(
                                  cartItems: state.items,
                                  customerClientId: selectedCustomer?.clientId, // Add customer ID if you have customer selection
                                  paymentMethod: selectedPayment!, // or your preferred payment method
                               ),
                              );
                              context.read<SellCartBloc>().add(ClearSellCart());
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

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _CartItemRow({
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