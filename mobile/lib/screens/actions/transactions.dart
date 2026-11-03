import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/transaction/transaction_bloc.dart';
import 'package:hajedi/bloc/transaction/transaction_event.dart';
import 'package:hajedi/bloc/transaction/transaction_state.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/widgets/loading.dart';
import 'package:hajedi/widgets/transaction/transaction_card.dart';
import 'package:hajedi/widgets/transaction/transaction_filter_tabs.dart';
import 'package:iconly/iconly.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  @override
  void initState() {
    super.initState();
    // Load transactions on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionBloc>().add(LoadTransactions());
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<TransactionBloc>().add(LoadReports());
        }
      },
   child:  Scaffold(
      appBar: AppBarComponent(
        title: loc.transactions,
        icon: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(IconlyLight.arrow_left_circle),
        ),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionsLoading) {
            return const Center(child: Loading());
          } else if (state is TransactionsLoaded) {
            return Column(
              children: [
                // Filter Tabs
                TransactionFilterTabs(
                  currentFilter: state.currentFilter,
                  onFilterChanged: (filter) {
                    context.read<TransactionBloc>().add(FilterTransactions(filter));
                  },
                ),
                const Divider(),
                // Transaction List
                Expanded(
                  child: state.filteredTransactions.isEmpty
                      ? Center(
                          child: Text(
                            loc.no_transactions_found,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = state.filteredTransactions[index];
                            return TransactionCard(transaction: transaction);
                          },
                        ),
                ),
              ],
            );
          } else if (state is TransactionsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(IconlyLight.danger, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TransactionBloc>().add(RefreshTransactions());
                    },
                    child: Text(loc.retry),
                  ),
                ],
              ),
            );
          }
          return Text(state.toString());
        },
      ),
    )
    );
  }
}