import 'package:flutter/material.dart';
import 'package:hajedi/data/transaction.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/screens/actions/transaction_detail.dart';
import 'package:intl/intl.dart';
import 'package:iconly/iconly.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {    
    return InkWell(
      onTap: () {
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetail(transaction: transaction),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Icon + Transaction Type + Customer Name | Amount + Date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: Icon + Transaction Type + Customer Name
                  Expanded(
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getTypeColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getTypeIcon(),
                            color: _getTypeColor(),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Transaction Type + Customer Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.typeLabel,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _getTypeColor(),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${transaction.displayTitle} • ${transaction.amount.toStringAsFixed(2)} frw',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right side: Amount + Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Amount
                      // Text(
                      //   '${transaction.amount.toStringAsFixed(2)} frw',
                      //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      //         color: _getAmountColor(),
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      // ),
      
                      const SizedBox(height: 4),
                      // Date
                      Row(
                        children: [
                          Text(
                            _formatDate(transaction.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                          Column(
                        children: [
                          const SizedBox(height: 25, width:10 ),
                          Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                        ],
                      ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // const SizedBox(height: 12),
              // Bottom row: Status
              // Row(
              //   children: [
              //     _buildStatusChip(context),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 12,
            color: _getStatusColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusLabel(context),
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (transaction.type) {
      case TransactionType.sale:
        return IconlyLight.buy;
      case TransactionType.purchase:
        return Icons.shopping_cart;
      case TransactionType.expense:
        return IconlyLight.wallet;
    }
  }

  Color _getTypeColor() {
    switch (transaction.type) {
      case TransactionType.sale:
        return Colors.green;
      case TransactionType.purchase:
        return Colors.blue;
      case TransactionType.expense:
        return Colors.orange;
    }
  }

  Color _getAmountColor() {
    switch (transaction.type) {
      case TransactionType.sale:
        return Colors.green;
      case TransactionType.purchase:
        return Colors.blue;
      case TransactionType.expense:
        return Colors.red;
    }
  }

  Color _getStatusColor() {
    switch (transaction.status.toLowerCase()) {
      case 'synced':
        return Colors.green;
      case 'pending':
        return Colors.amber;
      case 'failed':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (transaction.status.toLowerCase()) {
      case 'synced':
        return IconlyLight.tick_square;
      case 'pending':
        return IconlyLight.time_circle;
      case 'failed':
      case 'rejected':
        return IconlyLight.danger;
      default:
        return IconlyLight.info_circle;
    }
  }

  String _getStatusLabel(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    switch (transaction.status.toLowerCase()) {
      case 'synced':
        return loc.synced;
      case 'pending':
        return loc.pending;
      case 'failed':
      case 'rejected':
        return loc.failed;
      default:
        return transaction.status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${DateFormat('EEEE').format(date)}, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}