import 'package:flutter/material.dart';
import 'package:hajedi/data/product.dart';

class ProductCard extends StatelessWidget {
 final Product product;
  final bool isSell;
  const ProductCard({super.key, required this.product, this.isSell = true});

  @override
  Widget build(BuildContext context) {
    final currency = "FRW";
    double items;
    String label;
    double price;
    if(isSell){
        items = product.quantityInStock.toDouble();
        label = product.saleMethod;
        price = product.sellingPrice;
    }else{
        price = product.purchaseCost;
       if((product.purchaseMethod == "crate" && product.quantityInStock > product.unitsPerPackage) ||
          (product.purchaseMethod == "packet" && product.quantityInStock > product.unitsPerPackage)){
             items = product.quantityInStock / product.unitsPerPackage;
             label = product.purchaseMethod;
          }else if((product.purchaseMethod == "crate" && product.quantityInStock < product.unitsPerPackage) ||
           (product.purchaseMethod == "packet" && product.quantityInStock < product.unitsPerPackage)){
             items = product.quantityInStock.toDouble();
             label = product.saleMethod;
          }else if(product.purchaseMethod == "sack"){
            items = product.quantityInStock.toDouble();
            label = product.saleMethod;
          } else {
            items = product.quantityInStock.toDouble();
            label = product.purchaseMethod;
          }
    }

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16)
       ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end, 
            children: [
             Container(
              margin: const EdgeInsets.only(right: 5, bottom: 4),
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 91, 218, 97),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text('${items.toStringAsFixed(1)}\t$label',style: const TextStyle(fontSize: 10, color: Colors.white))
             )
            ]
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.amber,
            ),
            child: Center(
              child: Text(
                product.name.isNotEmpty
                    ? product.name[0].toUpperCase()
                    : '',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28
                  ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                product.name,
                style: Theme.of(context).textTheme.displaySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              )),
          const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Text(
                          '${_formatCurrency(price)} $currency',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                )
        ],
      ),
    );
  }
}

String _formatCurrency(double value) {
  return value.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
}
