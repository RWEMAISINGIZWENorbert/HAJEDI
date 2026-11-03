import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/customer/customer_bloc.dart';
import 'package:hajedi/bloc/customer/customer_event.dart';
import 'package:hajedi/data/customer.dart';
import 'package:hajedi/widgets/animated_snackbar.dart';
import 'package:hajedi/widgets/customer/customer_form.dart';
import 'package:iconly/iconly.dart';

Future<dynamic> showCustomerBottomSheetModal(
  BuildContext context,
  {Customer? customer}
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
                      customer != null
                          ? "Update Customer"
                          : 'Add New Customer',
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
                child: CustomerForm(
                  customer: customer,
                  isEditMode: customer != null,
                  onCustomerSaved: (Customer savedCustomer) {
                    if (customer != null) {
                      // Update existing customer
                      context.read<CustomerBloc>().add(
                        UpdateCustomerLocal(customer.clientId, savedCustomer),
                      );
                      showAnimatedSnackBar(context, "Customer Updated Successfully");
                    } else {
                      // Add new customer
                      context.read<CustomerBloc>().add(
                        AddCustomerLocal(savedCustomer),
                      );
                      showAnimatedSnackBar(context, "Customer Added successfully");
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