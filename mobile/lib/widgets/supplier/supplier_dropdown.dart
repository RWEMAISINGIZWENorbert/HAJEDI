import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hajedi/data/supplier.dart';
import 'package:hajedi/bloc/supplier/supplier_bloc.dart';
import 'package:hajedi/bloc/supplier/supplier_event.dart';
import 'package:hajedi/bloc/supplier/supplier_state.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/supplier/supplier_bottom_sheet_modal.dart';

class SupplierDropdown extends StatefulWidget {
  final Supplier? selectedSupplier;
  final Function(Supplier?) onSupplierChanged;
  const SupplierDropdown({super.key, this.selectedSupplier, required this.onSupplierChanged});

  @override
  State<SupplierDropdown> createState() => _SupplierDropdownState();
}

class _SupplierDropdownState extends State<SupplierDropdown> {
 
 @override
 void initState() {
    super.initState();
    context.read<SupplierBloc>().add(LoadSuppliers());
  }

  @override
  Widget build(BuildContext context) {
   final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<SupplierBloc, SupplierState>(
      builder: (context, state) {
        if (state is SuppliersLoadingState) {
          return Center( child: SizedBox.square(
                      dimension: 16,
                       child: CircularProgressIndicator(
                         strokeWidth: 2,
                         color: Theme.of(context).hintColor,
                       ),
                     ));
        } else if (state is SuppliersLoadedState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  l10n.supplier_name,
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
                child: ShadSelect<Supplier?>(
                  placeholder: Text('${l10n.select_supplier} (optional)'),
                  options: [
                    const ShadOption<Supplier?>(
                      value: null,
                      child: Text('No Supplier selected'),
                    ),
                    ...state.suppliers.map((supplier) => ShadOption<Supplier?>(
                      value: supplier,
                      child: Text(supplier.name),
                    )),
                  ],
                  selectedOptionBuilder: (context, customer) => customer == null
                      ? Text('${l10n.select_supplier} (optional)')
                      : Text(customer.name),
                  onChanged: widget.onSupplierChanged,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _showAddSupplierModal(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(l10n.add_supplier),
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
        // else if (state is SupplierError) {
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
        //           onPressed: () => _showAddSupplierModal(context),
        //           icon: const Icon(Icons.add, size: 16),
        //           label:  Text(l10n.new_supplier),
        //           style: TextButton.styleFrom(
        //             foregroundColor: Theme.of(context).primaryColor,
        //           ),
        //         ),
        //       ],
        //     ),
        //   );
        // }
        
        return const SizedBox();
      },
    );
  }

  void _showAddSupplierModal(BuildContext context) {
    showSupplierBottomSheetModal(context);
    context.read<SupplierBloc>().add(LoadSuppliers());
  }
}