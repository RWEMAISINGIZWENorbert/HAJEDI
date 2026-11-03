import 'package:flutter/material.dart';
import 'package:hajedi/data/supplier.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/animated_snackbar.dart';
import 'package:hajedi/widgets/input_text_field.dart';
import 'package:uuid/uuid.dart';

class SupplierForm extends StatefulWidget {
  final Supplier? supplier;
  final bool isEditMode;
  final Function(Supplier) onSupplierSaved;

  const SupplierForm({
    super.key,
    this.supplier,
    this.isEditMode = false,
    required this.onSupplierSaved,
  });

  @override
  State<SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<SupplierForm> {
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.supplier != null) {
      _nameController.text = widget.supplier!.name;
      _phoneNumberController.text = widget.supplier!.phoneNumber;
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

    final supplier = Supplier(
      id: widget.supplier?.id ?? "",
      clientId: widget.supplier?.clientId ?? Uuid().v4(),
      name: _nameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      address: widget.supplier?.address,
    );

    widget.onSupplierSaved(supplier);
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
                loc.supplier_name,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            InputTextField(
              controller: _nameController,
              labelText: loc.supplier_name,
              hintText: 'Enter ${loc.supplier_name}',
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
              widget.supplier != null
                  ? loc.edit_supplier
                  : loc.add_supplier,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }
}