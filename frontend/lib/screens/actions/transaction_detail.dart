import 'package:flutter/material.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/data/transaction.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/widgets/text.dart';
import 'package:hive/hive.dart';
import 'package:iconly/iconly.dart';

class TransactionDetail extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetail({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    // Extract items from rawData
    final items = _extractItems();
    final totalItems = _getTotalItems();
    
    return Scaffold(
      appBar: AppBarComponent(
        title: "",
        icon: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(IconlyLight.arrow_left_circle),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column with SimpleText widgets
              SimpleText(
                label: _getEntityLabel(),
              ),
              SimpleText(
                label: '${loc.items}: $totalItems',
              ),
              SimpleText(
                label: '${loc.amount}: ${transaction.amount.toStringAsFixed(2)} frw',
              ),
              const SizedBox(height: 24),
              
              // Table section
              if (items.isNotEmpty) ...[
                // Table header
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Name',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Price',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Quantity',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                // Table data rows
                ...items.map((item) => _buildItemRow(context, item)),
              ] else
                Center(
                  child: Text(
                    'No items available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEntityLabel() {
    switch (transaction.type) {
      case TransactionType.sale:
        return 'Customer: ${transaction.customerName ?? 'Unknown'}';
      case TransactionType.purchase:
        return 'Supplier: ${transaction.supplierName ?? 'Unknown'}';
      case TransactionType.expense:
        return 'Description: ${transaction.description ?? 'Unknown'}';
    }
  }

  List<Map<String, dynamic>> _extractItems() {
    if (transaction.rawData['items'] == null) {
      return [];
    }

    final itemsList = transaction.rawData['items'] as List;
    return itemsList.map((item) {
      if (item is Map<String, dynamic>) {
        return item;
      }
      return <String, dynamic>{};
    }).toList();
  }

  int _getTotalItems() {
    if (transaction.rawData['totalItems'] != null) {
      return (transaction.rawData['totalItems'] as num).toInt();
    }
    return _extractItems().length;
  }

  Widget _buildItemRow(BuildContext context, Map<String, dynamic> item) {
    final productId = item['productClientId']?.toString();
    final productBox = Hive.box<Product>('products');
    final product = productBox.get(productId);
    final name = product?.name ?? 'Unknown';
    final price = transaction.type == TransactionType.purchase
        ? (item['purchaseCost'] as num?)?.toDouble() ?? 0.0
        : (item['price'] as num?)?.toDouble() ?? 0.0;
    final quantity = (item['quantity'] as num?);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${price.toStringAsFixed(2)} frw',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              quantity.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}