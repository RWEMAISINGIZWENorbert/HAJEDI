import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/transaction/transaction_bloc.dart';
import 'package:hajedi/bloc/transaction/transaction_event.dart';
import 'package:hajedi/bloc/transaction/transaction_state.dart';
import 'package:hajedi/data/transaction.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/widgets/loading.dart';
import 'package:hajedi/widgets/text.dart';
import 'package:hive/hive.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';

class ReportDetails extends StatefulWidget {
  final ReportType reportType;
  final ReportPeriod? period;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportDetails({
    super.key,
    required this.reportType,
    this.period,
    this.startDate,
    this.endDate,
  });

  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  @override
  void initState() {
    super.initState();
    // Load report details on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionBloc>().add(LoadReportDetails(
            reportType: widget.reportType,
            period: widget.period,
            startDate: widget.startDate,
            endDate: widget.endDate,
          ));
    });
  }

  String _getDisplayText(AppLocalizations loc) {
    if (widget.startDate != null && widget.endDate != null) {
      // Display date range
      final formatter = DateFormat('dd/MM/yyyy');
      return '${formatter.format(widget.startDate!)} - ${formatter.format(widget.endDate!)}';
    } else if (widget.period != null ) {
      // Display localized period text
      switch (widget.period) {
        case ReportPeriod.today:
          return loc.today;
        case ReportPeriod.yesterday:
          return loc.yesterday;
        case ReportPeriod.thisWeek:
          return loc.this_week;
        case ReportPeriod.thisMonth:
          return loc.this_month;
        case ReportPeriod.thisYear:
          return loc.this_year;
        default:
          return loc.today;
      }
    }
    return loc.today;
  }

  String _getReportTypeLabel(AppLocalizations loc) {
    switch (widget.reportType) {
      case ReportType.sales:
        return loc.sales;
      case ReportType.purchases:
        return loc.purchases;
      case ReportType.expenses:
        return loc.expenses;
      case ReportType.credits:
        return loc.credits;
      case ReportType.creditsCollected:
        return loc.payedCredits;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return PopScope(
      onPopInvokedWithResult: (didPop, result){
         context.read<TransactionBloc>().add(LoadReports(period: widget.period));
      },
      child: Scaffold(
        appBar: AppBarComponent(
          title: '',
          icon: InkWell(
            onTap: () {
              Navigator.pop(context);
              context.read<TransactionBloc>().add(LoadReports(period: widget.period));
            },
            child: const Icon(IconlyLight.arrow_left_circle),
          ),
        ),
        body: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is ReportDetailsLoading) {
              return const Center(child: Loading());
            }
      
            if (state is ReportDetailsLoaded) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Section 2: Report type and date range/period
                      Center(
                        child: SimpleText(
                          label: '${_getReportTypeLabel(loc)}\n${_getDisplayText(loc)}',
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Section 3: Table
                      if (state.transactions.isEmpty)
                        Center(
                          child: Text(
                            'No transactions found',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        )
                      else
                        _buildTable(context, state.transactions),
                    ],
                  ),
                ),
              );
            }
      
            if (state is TransactionsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(IconlyLight.danger, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
      
            return const Center(child: Loading());
          },
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<Transaction> transactions) {
  // Determine table structure based on report type
  if (widget.reportType == ReportType.credits ||
      widget.reportType == ReportType.creditsCollected) {
    // Credits table: 2 columns (Customer, Amount)
    return Column(
      children: [
        // Table header
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Customer',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Amount',
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
        ...transactions.map((transaction) => _buildCreditRow(context, transaction)),
      ],
    );
  } else {
    // Sales/Purchases/Expenses table: 3 columns (Items, Quantity, Amount)
    return Column(
      children: [
        // Table header
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Items',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Quantity',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Amount',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const Divider(),
        // Table data rows - now each transaction can have multiple item rows
        ...transactions.expand((transaction) => _buildItemRows(context, transaction)),
      ],
    );
  }
}

List<Widget> _buildItemRows(BuildContext context, Transaction transaction) {
  // Extract items from rawData
  final items = transaction.rawData['items'] as List?;
  if (items == null || items.isEmpty) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'No items',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '-',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${transaction.amount.toStringAsFixed(2)} frw',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // Loop over all items and create a row for each
  return items.map<Widget>((item) {
    if (item is! Map<String, dynamic>) {
      return const SizedBox.shrink();
    }

    final productId = item['productClientId']?.toString();
    final productBox = Hive.box<Product>('products');
    final product = productBox.get(productId);
    final name = product?.name ?? 'Unknown';
    
    final quantity = (item['quantity'] as num?);
    final price = transaction.type == TransactionType.purchase
        ? (item['purchaseCost'] as num?)?.toDouble() ?? 0.0
        : (item['price'] as num?)?.toDouble() ?? 0.0;
    final itemAmount = (item['totalAmount'] as num?)?.toDouble() ?? 
                      (price * (quantity?.toDouble() ?? 0.0));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              quantity.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${itemAmount.toStringAsFixed(2)} frw',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }).toList();
}

  Widget _buildCreditRow(BuildContext context, Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              transaction.customerName ?? 'Unknown',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${transaction.amount.toStringAsFixed(2)} frw',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }


}