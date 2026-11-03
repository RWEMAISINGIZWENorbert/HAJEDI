import 'package:flutter/material.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/credit/payment_method_selector.dart';

Future<String?> showPaymentMethodDialog(BuildContext context) {
  String? selectedMethod;

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      final loc = AppLocalizations.of(context)!;
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            loc.select_payment_method,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PaymentMethodSelector(
                label: loc.cash,
                isSelected: selectedMethod == 'cash',
                onTap: () {
                  setState(() {
                    selectedMethod = 'cash';
                  });
                },
              ),
              const SizedBox(height: 8),
              PaymentMethodSelector(
                label: loc.mobile,
                isSelected: selectedMethod == 'mobile',
                onTap: () {
                  setState(() {
                    selectedMethod = 'mobile';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                loc.cancel,
                style: const TextStyle(color: Color.fromARGB(255, 228, 48, 36)),
              ),
            ),
            TextButton(
              onPressed: selectedMethod != null
                  ? () => Navigator.of(context).pop(selectedMethod)
                  : null,
              child: Text(
                loc.confirm,
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      );
    },
  );
}