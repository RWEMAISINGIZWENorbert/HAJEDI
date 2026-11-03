import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/supplier/supplier_bloc.dart';
import 'package:hajedi/bloc/supplier/supplier_event.dart';
import 'package:hajedi/data/supplier.dart';
import 'package:hajedi/widgets/animated_snackbar.dart';
import 'package:hajedi/widgets/supplier/supplier_form.dart';
import 'package:iconly/iconly.dart';

Future<dynamic> showSupplierBottomSheetModal(
  BuildContext context,
  {Supplier? supplier}
){
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12), 
          topRight: Radius.circular(12)
        ),
        color: Theme.of(context).cardColor,
      ),
      child: SingleChildScrollView(
         child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      supplier != null
                          ? "Update Supplier"
                          : 'Add New Supplier',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(IconlyLight.close_square),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Form
              Padding(
                padding: const EdgeInsets.all(16),
                child: SupplierForm(
                  supplier: supplier,
                  isEditMode: supplier != null,
                  onSupplierSaved: (Supplier savedSupplier) {
                    if (supplier != null) {
                      // Update existing supplier
                      context.read<SupplierBloc>().add(
                        UpdateSupplierLocal(supplier.clientId, savedSupplier),
                      );
                      showAnimatedSnackBar(context, "Supplier Updated Successfully");
                    } else {
                      // Add new supplier
                      context.read<SupplierBloc>().add(
                        AddSupplierLocal(savedSupplier),
                      );
                      showAnimatedSnackBar(context, "Supplier Added successfully");
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          )
        ),
      ),
    )
  );
}