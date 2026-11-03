import 'package:flutter/material.dart';
import 'package:hajedi/bloc/transaction/transaction_event.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:iconly/iconly.dart';

class TransactionFilterTabs extends StatelessWidget {
  final TransactionFilter currentFilter;
  final Function(TransactionFilter) onFilterChanged;

  const TransactionFilterTabs({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            context,
            TransactionFilter.all,
            IconlyLight.category,
            loc.all_transactions,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            TransactionFilter.sales,
            IconlyLight.buy,
            loc.sales,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            TransactionFilter.purchases,
            Icons.shopping_cart,
            loc.purchases,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            TransactionFilter.expenses,
            IconlyLight.wallet,
            loc.expenses,
          ),
        ],
      ),
    );
  }

Widget _buildFilterChip(
  BuildContext context,
  TransactionFilter filter,
  IconData icon,
  String label,
) {
  final isSelected = currentFilter == filter;
  final theme = Theme.of(context);
  
  if (isSelected) {
    // Active tab: rounded container with primary color background and white text
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  } else {
    // Inactive tab: normal text with theme.hintColor
    return InkWell(
      onTap: () => onFilterChanged(filter),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon(icon, size: 16, color: theme.hintColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: theme.hintColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

  Color _getFilterColor(TransactionFilter filter) {
    switch (filter) {
      case TransactionFilter.all:
        return Colors.blue;
      case TransactionFilter.sales:
        return Colors.green;
      case TransactionFilter.purchases:
        return Colors.blue;
      case TransactionFilter.expenses:
        return Colors.orange;
    }
  }
}