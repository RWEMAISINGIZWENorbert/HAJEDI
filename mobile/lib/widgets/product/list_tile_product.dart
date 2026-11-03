
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hajedi/data/product.dart';

class ListTileProduct extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ListTileProduct({super.key, required this.product, this.onTap});

  Color _generateColor(String text) {
    final int hash = text.codeUnitAt(0);
    final double hue = (hash * 137.5) % 360;
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
  }

  @override
  Widget build(BuildContext context) {
    double items;
    String label;
    if((product.saleMethod == "unit" && product.quantityInStock > product.unitsPerPackage) ||
      (product.saleMethod == "bottles" && product.quantityInStock > product.unitsPerPackage)){
      items = product.quantityInStock / product.unitsPerPackage;
      label = product.purchaseMethod;
    }else if((product.saleMethod == "unit" && product.quantityInStock < product.unitsPerPackage) ||
             (product.saleMethod == "bottles" && product.quantityInStock < product.unitsPerPackage)){
      items = product.quantityInStock.toDouble();
      label = product.saleMethod;
    }else {
      items = product.quantityInStock.toDouble();
      label = product.saleMethod;
    }
    
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _generateColor(product.name),
        child: Center(
          child: Text(
            product.name[0].toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              decoration: TextDecoration.none
            ),
          ),
        ),
      ),
      title: Text(
        product.name, 
        style: Theme.of(context).textTheme.displayMedium,
      ),
      subtitle: Text(
        "${items.toStringAsFixed(1)}     $label",
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Theme.of(context).hintColor,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none
         ),
      ),
      trailing: Text(
        "${product.sellingPrice} RWF",
        style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.green.shade700,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none
         ),
      ),
    );
  }
}