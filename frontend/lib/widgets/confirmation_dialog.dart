
import 'package:flutter/material.dart';
import 'package:hajedi/l10n/app_localizations.dart';

Future<dynamic> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) {
  final loc = AppLocalizations.of(context)!;
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.no, style: const TextStyle(color: Color.fromARGB(255, 228, 48, 36)),),
          ),
          TextButton(
            onPressed: onConfirm,
            child: Text(loc.yes, style: const TextStyle(color: Colors.green),),
          ),
      ],
    );
   },
  );
}