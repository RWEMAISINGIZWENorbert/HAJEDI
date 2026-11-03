import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/product/product_bloc.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/widgets/loading.dart';
import 'package:hajedi/widgets/product/product_card.dart';
import 'package:hajedi/widgets/text.dart';
import 'package:iconly/iconly.dart';
import 'package:hajedi/bloc/purchase_cart/purchase_cart_bloc.dart';
import 'package:hajedi/bloc/purchase_cart/purchase_cart_event.dart';
import 'package:hajedi/data/cart_item.dart';
import 'package:hajedi/widgets/purchase/purchase_cart.dart';

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  State<Purchase> createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {

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
    return  BlocConsumer<ProductBloc, ProductState>(
      listener: (BuildContext context, ProductState state) { 

       },
      builder: (BuildContext context, ProductState state) {
        if(state is ProductsLoading){
          return Scaffold(
            body: Center(child: Loading())
          );
        }else if(state is ProductsLoadedSuccessfully){
           List<Product> products = state.products;
           return Scaffold(
            appBar: AppBarComponent(
              title: loc.purchase,
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
                    padding:  const EdgeInsets.symmetric(horizontal: 12),
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
                            onTap: () async {
                              // Add the product to the cart (CartBloc handles quantity increment if item exists)
                              context.read<PurchaseCartBloc>().add(
                                AddToPurchaseCart(
                                  CartItem(
                                    productClientId: product.clientId,
                                    productName: product.name,
                                    unitPrice: product.purchaseCost, // Use purchase cost for purchases
                                    quantity: product.purchaseMethod == "sack" ? 0.5 : 1 ,
                                  ),
                                ),
                              );
  
                              // Open the purchase cart bottom sheet
                              await showPurchaseCartBottomSheet(context);
                            },
                            child: ProductCard(product: product, isSell: false),
                          );
                        }
                    )
                  )
                )
               ],
            ),
           );
         }else {
           return SimpleText(label: "Error $state");
         }
       }
    );
  }
}