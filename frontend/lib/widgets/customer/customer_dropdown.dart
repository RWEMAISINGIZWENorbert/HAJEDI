import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hajedi/data/customer.dart';
import 'package:hajedi/bloc/customer/customer_bloc.dart';
import 'package:hajedi/bloc/customer/customer_event.dart';
import 'package:hajedi/bloc/customer/customer_state.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/customer/customer_bottom_sheet_modal.dart';

class CustomerDropdown extends StatefulWidget {
  final Customer? selectedCustomer;
  final Function(Customer?) onCustomerChanged;

  const CustomerDropdown({
    super.key,
    this.selectedCustomer,
    required this.onCustomerChanged,
  });

  @override
  State<CustomerDropdown> createState() => _CustomerDropdownState();
}

class _CustomerDropdownState extends State<CustomerDropdown> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(LoadCustomers());
  }

  @override
  Widget build(BuildContext context) {
     final loc = AppLocalizations.of(context)!;
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomersLoadingState) {
          return  Center( child: SizedBox.square(
                      dimension: 16,
                       child: CircularProgressIndicator(
                         strokeWidth: 2,
                         color: Theme.of(context).hintColor,
                       ),
                     ));
        } else if (state is CustomersLoadedState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  loc.customer,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
              const SizedBox(height: 8),
              ShadTheme(
                data: ShadThemeData(
                  colorScheme:  ShadColorScheme(
               background: Colors.white,
          cardForeground: Colors.white,
          card: Colors.white,
          // popover: Colors.black,
          popover: Theme.of(context).cardColor,
          popoverForeground: Theme.of(context).hintColor,
          primaryForeground: Colors.white,
          foreground: Theme.of(context).hintColor,
          muted: Colors.white,
          mutedForeground: Colors.white,
          primary: Colors.amber,
          secondary: Colors.white,
          secondaryForeground: Colors.white,
          selection: Colors.white,
          accent: Colors.amber,
          accentForeground: Colors.white,
          border: const Color.fromARGB(255, 61, 61, 61),
          destructive: Colors.white,
          destructiveForeground: Colors.white,
          input: const Color.fromARGB(255, 49, 49, 49),
          // input: Colors.yellow,
          ring: Colors.black87,
                  ),
                  brightness: Brightness.dark,
                ),
                child: ShadSelect<Customer?>(
                  placeholder: Text('${loc.select_customer}'),
                  options: [
                    const ShadOption<Customer?>(
                      value: null,
                      child: Text('No customer selected'),
                    ),
                    ...state.customers.map((customer) => ShadOption<Customer?>(
                      value: customer,
                      child: Text(customer.name),
                    )),
                  ],
                  selectedOptionBuilder: (context, customer) => customer == null
                      ? Text('${loc.select_customer} (optional)')
                      : Text(customer.name),
                  onChanged: widget.onCustomerChanged,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _showAddCustomerModal(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(loc.add_customer),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } 
        // else if (state is CustomerError) {
        //   return Padding(
        //     padding: const EdgeInsets.all(16),
        //     child: Column(
        //       children: [
        //         Text(
        //           'Error loading customers: ${state.errorMessage}',
        //           style: Theme.of(context).textTheme.bodySmall?.copyWith(
        //             color: Colors.red,
        //           ),
        //         ),
        //         const SizedBox(height: 8),
        //         TextButton.icon(
        //           onPressed: () => _showAddCustomerModal(context),
        //           icon: const Icon(Icons.add, size: 16),
        //           label: const Text('Add New Customer'),
        //           style: TextButton.styleFrom(
        //             foregroundColor: Theme.of(context).primaryColor,
        //           ),
        //         ),
        //       ],
        //     ),
        //   );
        // }
        else {
         return const SizedBox();
        }
      },
    );
  }

  void _showAddCustomerModal(BuildContext context) {
    showCustomerBottomSheetModal(context);
  }
} 