import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/product/product_bloc.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/animated_snackbar.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/widgets/input_text_field.dart';
import 'package:hajedi/widgets/primary_button.dart';
import 'package:hajedi/widgets/select_option.dart';
import 'package:hajedi/widgets/text.dart';
import 'package:iconly/iconly.dart';
import 'package:uuid/uuid.dart';

class NewProduct extends StatefulWidget {
  const NewProduct({super.key});

  @override
  State<NewProduct> createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  final _nameController = TextEditingController();
  final _purchaseCostController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _unitsPerPackageController = TextEditingController();
  final _quantityInStockController = TextEditingController();

  String? _productType;
  String? _purchaseMethod;
  String? _saleMethod;

  @override
  void dispose() {
    _nameController.dispose();
    _purchaseCostController.dispose();
    _sellingPriceController.dispose();
    _unitsPerPackageController.dispose();
    _quantityInStockController.dispose();
    super.dispose();
  }

void _registerProduct() {
  final name = _nameController.text.trim();

  final sellingPrice = double.tryParse(
    _sellingPriceController.text.trim(),
  );

  final unitsPerPackage = int.tryParse(
    _unitsPerPackageController.text.trim(),
  );

  final quantityInStock = int.tryParse(
    _quantityInStockController.text.trim(),
  );

  final purchaseMethodRequiresCost =
      _purchaseMethod == 'packet' ||
      _purchaseMethod == 'crate' ||
      _purchaseMethod == 'sack';

  final purchaseCost = purchaseMethodRequiresCost
      ? double.tryParse(_purchaseCostController.text.trim())
      : 0.0;

  if (name.isEmpty ||
      sellingPrice == null ||
      unitsPerPackage == null ||
      quantityInStock == null ||
      purchaseCost == null ||
      _productType == null ||
      _purchaseMethod == null ||
      _saleMethod == null) {
    final loc = AppLocalizations.of(context)!;

    showAnimatedSnackBar(
      context,
      loc.please_fill_all_fields,
      isSuccess: false,
    );
    return;
  }

  if (purchaseCost < 0 ||
      sellingPrice < 0 ||
      unitsPerPackage < 1 ||
      quantityInStock < 0) {
    showAnimatedSnackBar(
      context,
      'Please enter valid product values',
      isSuccess: false,
    );
    return;
  }

  final product = Product(
    id: '',
    clientId: const Uuid().v4(),
    name: name,
    productType: _productType!,
    purchaseMethod: _purchaseMethod!,
    saleMethod: _saleMethod!,
    purchaseCost: purchaseCost,
    sellingPrice: sellingPrice,
    unitsPerPackage: unitsPerPackage,
    quantityInStock: quantityInStock,
    isSynced: false,
  );

  context.read<ProductBloc>().add(
        RegisterLocalProduct(product: product),
      );
}

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBarComponent(
        icon: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            IconlyLight.arrow_left_circle,
          ),
        ),
        title: loc.new_product,
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductRegisteredSuccessfully) {
            showAnimatedSnackBar(
      context,
      state.message,
    );

    Navigator.pop(context);
  }

  if (state is RegisterProductFailure) {
    showAnimatedSnackBar(
      context,
      state.message,
      isSuccess: false,
    );
  }
},
        builder: (context, state) {
          final isLoading = state is RegisterProductLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SimpleText(label: '${loc.name}:'),
                InputTextField(
                  controller: _nameController,
                  labelText: loc.name,
                  hintText: '${loc.enter} ${loc.name}',
                  keyboardType: TextInputType.name,
                  redaOnly: isLoading,
                ),
                const SizedBox(height: 14),

                SimpleText(label: '${loc.product_type}:'),
                SelectOption(
                  label: "Product type",
                  options: const [
                    'item',
                    'kg',
                  ],
                  onSelect: isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _productType = value;
                          });
                        },
                ),
                const SizedBox(height: 14),

                SimpleText(label: '${loc.purchase_method}:'),
                SelectOption(
                  label: 'purchase',
                  options: const [
                    'packet',
                    'crate',
                    'sack',
                    'unit',
                    'kg',
                  ],
  onSelect: isLoading
      ? null
      : (value) {
          setState(() {
            _purchaseMethod = value;

            if (value == 'unit' || value == 'kg') {
              _purchaseCostController.clear();
            }
          });
        },
),
                const SizedBox(height: 14),

                SimpleText(label: '${loc.sale_method}:'),
SelectOption(
  label: 'sale',
  options: const [
    'unit',
    'kg',
    'gram',
    'bottles',
  ],
  onSelect: isLoading
      ? null
      : (value) {
          setState(() {
            _saleMethod = value;
          });
        },
),
                const SizedBox(height: 14),

                if (_purchaseMethod == 'packet' || _purchaseMethod == 'crate' || _purchaseMethod == 'sack') ...[
  SimpleText(
    label: '${loc.purchase_cost_per} 1 $_purchaseMethod:',
  ),
  InputTextField(
    controller: _purchaseCostController,
    labelText: '${loc.purchase_cost_per} 1 $_purchaseMethod',
    hintText: '0',
    keyboardType: const TextInputType.numberWithOptions(
      decimal: true,
    ),
    formatNumber: true,
    redaOnly: isLoading,
  ),
  const SizedBox(height: 14),
],
                const SizedBox(height: 14),

                if (_saleMethod != null) ...[
  SimpleText(
    label: '${loc.selling_price_per} 1 $_saleMethod:',
  ),
  InputTextField(
    controller: _sellingPriceController,
    labelText: '${loc.selling_price_per} 1 $_saleMethod',
    hintText: '0',
    keyboardType: const TextInputType.numberWithOptions(
      decimal: true,
    ),
    formatNumber: true,
    redaOnly: isLoading,
  ),
  const SizedBox(height: 14),
],
                const SizedBox(height: 14),

                SimpleText(label: '${loc.units_per_package}:'),
                InputTextField(
                  controller: _unitsPerPackageController,
                  labelText: loc.units_per_package,
                  hintText: '1',
                  keyboardType: TextInputType.number,
                  formatNumber: true,
                  redaOnly: isLoading,
                ),
                const SizedBox(height: 14),

                SimpleText(label: '${loc.quantity_in_stock}:'),
                InputTextField(
                  controller: _quantityInStockController,
                  labelText: loc.quantity_in_stock,
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  formatNumber: true,
                  redaOnly: isLoading,
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  onPressed: _registerProduct,
                  label: loc.save,
                  isLoading: isLoading,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}