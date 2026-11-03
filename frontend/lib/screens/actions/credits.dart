import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/sale/sale_bloc.dart';
import 'package:hajedi/bloc/sale/sale_event.dart';
import 'package:hajedi/bloc/sale/sale_state.dart';
import 'package:hajedi/data/customer.dart';
import 'package:hajedi/data/sale.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/credit/show_payment_method_dialog.dart';
import 'package:hive/hive.dart';
import 'package:iconly/iconly.dart';

class Credits extends StatefulWidget {
  const Credits({super.key});

  @override
  State<Credits> createState() => _CreditsState();
}

class _CreditsState extends State<Credits> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleBloc>().add(LoadCreditSales());
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBarComponent(
        title: loc.credits,
        icon: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(IconlyLight.arrow_left_circle),
        ), 
      ),
      body: BlocBuilder<SaleBloc, SaleState>(
        builder: (context, state) {
          if (state is SalesLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SalesLoadedState) {
            if (state.sales.isEmpty) {
              return Center(
                child: Text(loc.no_credits),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.sales.length,
              itemBuilder: (context, index) {
                return _buildCreditSaleCard(context, state.sales[index]);
              },
            );
          }

          if (state is SaleErrorState) {
            return Center(
              child: Text(state.message),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildCreditSaleCard(BuildContext context, Sale sale) {
    final customerBox = Hive.box<Customer>('customers');
    final customer = customerBox.get(sale.customerClientId);
    final customerName = customer?.name ?? 'Unknown';
    final loc = AppLocalizations.of(context)!;

    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${loc.customer}: $customerName',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${loc.items}: ${sale.totalItems}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${loc.amount}: ${sale.totalAmount.toStringAsFixed(0)} RWF',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final selectedMethod = await showPaymentMethodDialog(context);
                  if (selectedMethod != null) {
                      context.read<SaleBloc>().add(
                          PayCreditSaleLocal(
                            clientId: sale.clientId,
                            newPaymentMethod: selectedMethod,
                          ),
                       );
                    }
                 },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(loc.pay_credit),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}