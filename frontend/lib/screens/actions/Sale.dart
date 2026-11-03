import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/sell_cart/sell_cart_bloc.dart';
import 'package:hajedi/bloc/sell_cart/sell_cart_event.dart';
import 'package:hajedi/bloc/sell_cart/sell_cart_state.dart';
import 'package:hajedi/bloc/product/product_bloc.dart';
import 'package:hajedi/data/cart_item.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/widgets/loading.dart';
import 'package:hajedi/widgets/product/product_card.dart';
import 'package:hajedi/widgets/sell/sell_cart.dart';
import 'package:hajedi/widgets/text.dart';
import 'package:iconly/iconly.dart';

class Sale extends StatefulWidget {
  const Sale({super.key});

  @override
  State<Sale> createState() => _SaleState();
}

class _SaleState extends State<Sale> {
  
  @override
  void initState() {
    super.initState();
    // Automatically load local products when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(LoadLocalProducts());
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BlocConsumer<ProductBloc, ProductState>(
      listener: (BuildContext context, ProductState state) { 
       },
      builder: (BuildContext context, ProductState state) {
        if(state is ProductsLoading){
          return Scaffold(
            body: Center(child: Loading())
          );
        }else if(state is ProductsLoadedSuccessfully){
           List<Product> products = state.products;
           return BlocConsumer<SellCartBloc, SellCartState>(
             listener: (context, cartState) {
               // Optional: Show snackbar when item is added
             },
             builder: (context, cartState) {
               final cartItems = cartState is SellCartLoadedState ? cartState.items : [];
               final totalAmount = cartState is SellCartLoadedState ? cartState.totalAmount : 0.0;
               final totalQuantity = cartItems.fold<num>(0, (sum, item) => sum + item.quantity);
               
               return Scaffold(
                 appBar: AppBarComponent(
                   title: loc.sell,
                   icon: InkWell(
                       onTap: () {
                         Navigator.pop(context);
                       },
                       child: const Icon(IconlyLight.arrow_left_circle),
                   ),
                 ),
                 body: products.isEmpty
                       ? Center(child: Text(loc.no_products_found))
                       : Column(
                    children: [
                      const SizedBox(height: 12),
                       Expanded(
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 12),
                         child: GridView.builder(
                             gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                               maxCrossAxisExtent: 160,
                               crossAxisSpacing: 15,
                               mainAxisSpacing: 10,
                               childAspectRatio: 0.8,
                             ),
                             itemCount: products.length,
                             itemBuilder: (context, index) {
                               final product = products[index];
                               return InkWell(
                                 onTap: () {
                                   final cartItem = CartItem(
                                       productClientId: product.clientId,
                                       productName: product.name,
                                       quantity: 1,
                                       unitPrice: product.sellingPrice,
                                   );
                                   context.read<SellCartBloc>().add(AddToSellCart(cartItem));
                                 },
                                 child: ProductCard(product: product, isSell: true),
                               );
                             }
                         )
                       )
                     ),
                     // Cart summary bar at the bottom
                     if (cartItems.isNotEmpty)
                       InkWell(
                         onTap: () {
                           showSellCartBottomSheet(context);
                         },
                         child: Container(
                           margin: const EdgeInsets.all(16),
                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                           decoration: BoxDecoration(
                             color: Theme.of(context).primaryColor,
                             borderRadius: BorderRadius.circular(12),
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.black.withOpacity(0.1),
                                 blurRadius: 8,
                                 offset: const Offset(0, -2),
                               ),
                             ],
                           ),
                           child: Row(
                             children: [
                               // Left arrow ico
                               const SizedBox(width: 12),
                               // Cart summary text
                               Expanded(
                                 child: Text(
                                   '$totalQuantity ${loc.items} = $totalAmount frw',
                                   style: const TextStyle(
                                     color: Colors.white,
                                     fontSize: 16,
                                     fontWeight: FontWeight.w600,
                                   ),
                                 ),
                               ),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.end,
                                 children: [
                                   const Icon(
                                     IconlyLight.arrow_right,
                                     color: Colors.white,
                                     size: 24,
                                   ),
                                 ],
                               ),
                         
                             ],
                           ),
                         ),
                       ),
                  ],
               ),
              );
             },
           );
         }else {
           return SimpleText(label: "Error $state");
         }
       }
    );
  }
}