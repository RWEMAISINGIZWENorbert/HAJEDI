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

class EditProduct extends StatefulWidget {
  final Product product;

  const EditProduct({
    super.key,
    required this.product,
  });

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  late final TextEditingController _nameController;
  late final TextEditingController _purchaseCostController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _unitsPerPackageController;
  late final TextEditingController _quantityInStockController;

  late String _productType;
  late String _purchaseMethod;
  late String _saleMethod;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nameController = TextEditingController(text: product.name);
    _purchaseCostController = TextEditingController(
      text: product.purchaseCost.toString(),
    );
    _sellingPriceController = TextEditingController(
      text: product.sellingPrice.toString(),
    );
    _unitsPerPackageController = TextEditingController(
      text: product.unitsPerPackage.toString(),
    );
    _quantityInStockController = TextEditingController(
      text: product.quantityInStock.toString(),
    );

    _productType = product.productType;
    _purchaseMethod = product.purchaseMethod;
    _saleMethod = product.saleMethod;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purchaseCostController.dispose();
    _sellingPriceController.dispose();
    _unitsPerPackageController.dispose();
    _quantityInStockController.dispose();
    super.dispose();
  }

  void _updateProduct() {
    final loc = AppLocalizations.of(context)!;

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
        _purchaseMethod == 'crate';

    final purchaseCost = purchaseMethodRequiresCost
        ? double.tryParse(_purchaseCostController.text.trim())
        : 0.0;

    if (name.isEmpty ||
        sellingPrice == null ||
        unitsPerPackage == null ||
        quantityInStock == null ||
        purchaseCost == null) {
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

    final updatedProduct = widget.product.copyWith(
      name: name,
      productType: _productType,
      purchaseMethod: _purchaseMethod,
      saleMethod: _saleMethod,
      purchaseCost: purchaseCost,
      sellingPrice: sellingPrice,
      unitsPerPackage: unitsPerPackage,
      quantityInStock: quantityInStock,
      isSynced: false,
      updatedAt: DateTime.now(),
    );

    context.read<ProductBloc>().add(
          UpdateLocalProduct(
            clientId: widget.product.clientId,
            product: updatedProduct,
          ),
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
        title: 'Edit ${loc.products}',
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductsUpdatedSuccessfully) {
            showAnimatedSnackBar(
              context,
              state.message,
            );

            Navigator.pop(context);
          }

          if (state is ProductUpdateFailure) {
            showAnimatedSnackBar(
              context,
              state.message,
              isSuccess: false,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ProductsLoading;

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
                  hintText: loc.name,
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
                  initialValue: _productType,
                  isEditMode: true,
                  onSelect: isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _productType = value;
                            });
                          }
                        },
                ),
                const SizedBox(height: 14),

                SimpleText(label: '${loc.purchase_method}:'),
                SelectOption(
                  label: loc.purchase_method,
                  options: const [
                    'packet',
                    'crate',
                    'unit',
                    'kg',
                  ],
                  initialValue: _purchaseMethod,
                  isEditMode: true,
                  onSelect: isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _purchaseMethod = value;

                              if (value == 'unit' || value == 'kg') {
                                _purchaseCostController.clear();
                              }
                            });
                          }
                        },
                ),
                const SizedBox(height: 14),

                SimpleText(label: '${loc.sale_method}:'),
                SelectOption(
                  label: loc.sale_method,
                  options: const [
                    'unit',
                    'kg',
                    'gram',
                    'bottles',
                  ],
                  initialValue: _saleMethod,
                  isEditMode: true,
                  onSelect: isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _saleMethod = value;
                            });
                          }
                        },
                ),
                const SizedBox(height: 14),

                if (_purchaseMethod == 'packet' ||
                    _purchaseMethod == 'crate') ...[
                  SimpleText(
                    label:
                        '${loc.purchase_cost_per} 1 $_purchaseMethod:',
                  ),
                  InputTextField(
                    controller: _purchaseCostController,
                    labelText:
                        '${loc.purchase_cost_per} 1 $_purchaseMethod',
                    hintText: '0',
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    formatNumber: true,
                    redaOnly: isLoading,
                  ),
                  const SizedBox(height: 14),
                ],

                if (_saleMethod.isNotEmpty) ...[
                  SimpleText(
                    label: '${loc.selling_price_per} 1 $_saleMethod:',
                  ),
                  InputTextField(
                    controller: _sellingPriceController,
                    labelText:
                        '${loc.selling_price_per} 1 $_saleMethod',
                    hintText: '0',
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    formatNumber: true,
                    redaOnly: isLoading,
                  ),
                  const SizedBox(height: 14),
                ],

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
                  onPressed: _updateProduct,
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