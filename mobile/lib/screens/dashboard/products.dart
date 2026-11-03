import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/product/product_bloc.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/screens/product/product_details.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/widgets/product/list_tile_product.dart';
import 'package:hajedi/widgets/loading.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadLocalProducts());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBarComponent(
        title: loc.products,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductsLoading) {
            return Center(
              child: Loading(),
            );
          }

          if (state is ProductLoadFailure) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is ProductsLoadedSuccessfully) {
            if (state.products.isEmpty) {
              return Center(
                child: Text(loc.no_products_found),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
               return ListTileProduct(
                  product: state.products[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                         builder: (_) => ProductDetails(
                         product: state.products[index],
                       ),
                     ),
                   );
                  },
               );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => { Navigator.pushNamed(context, '/new-product') },
        icon: const Icon(Icons.add),
        label: Text(loc.new_product),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}