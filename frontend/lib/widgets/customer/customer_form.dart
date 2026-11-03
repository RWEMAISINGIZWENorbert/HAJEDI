import 'package:flutter/material.dart';
import 'package:hajedi/data/customer.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/animated_snackbar.dart';
import 'package:hajedi/widgets/input_text_field.dart';
import 'package:uuid/uuid.dart';

class CustomerForm extends StatefulWidget {
  final Customer? customer;
  final bool isEditMode;
  final Function(Customer) onCustomerSaved;

  const CustomerForm({
    super.key,
    this.customer,
    this.isEditMode = false,
    required this.onCustomerSaved,
  });

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _phoneNumberController.text = widget.customer!.phoneNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _save() {
    final loc = AppLocalizations.of(context)!;
    
    if (_nameController.text.trim().isEmpty) {
      showAnimatedSnackBar(context, loc.please_fill_all_fields, isSuccess: false);
      return;
    }

    if (_phoneNumberController.text.trim().isEmpty) {
      showAnimatedSnackBar(context, loc.please_fill_all_fields, isSuccess: false);
      return;
    }

    final customer = Customer(
      id: widget.customer?.id ?? "",
      clientId: widget.customer?.clientId ?? Uuid().v4(),
      name: _nameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      address: widget.customer?.address,
      creditLimit: widget.customer?.creditLimit,
    );

    widget.onCustomerSaved(customer);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                loc.customer_name,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            InputTextField(
              controller: _nameController,
              labelText: loc.customer_name,
              hintText: 'Enter ${loc.customer_name}',
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Phone Number Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                loc.phone_number,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            InputTextField(
              controller: _phoneNumberController,
              labelText: loc.phone_number,
              hintText: 'Enter ${loc.phone_number}',
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              widget.customer != null
                  ? loc.edit_customer
                  : loc.add_customer,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }
}