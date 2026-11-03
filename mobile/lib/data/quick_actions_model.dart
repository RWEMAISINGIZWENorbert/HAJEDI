import 'package:flutter/material.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iconsax/iconsax.dart';

class QuickActionsModel {
  String Function(AppLocalizations) label;
  Widget icon;
  Color color;

  QuickActionsModel({required this.label, required this.icon, required this.color});

  static List<QuickActionsModel> initActions() {
    List<QuickActionsModel> actions = [];

    actions.add(
      QuickActionsModel(
        label: (l10n) => l10n.sell,
        icon: const Icon(
          Icons.sell,
          color: Colors.white,
          size: 28,
        ),
        color: const Color.fromARGB(255, 87, 197, 92),
      ),
    );
    actions.add(
      QuickActionsModel(
        label: (l10n) => l10n.purchase,
        icon: const Icon(
          Icons.shopping_cart,
          color: Colors.white,
          size: 28,
        ),
        color: const Color.fromARGB(255, 223, 67, 67),
      ),
    );
    actions.add(
      QuickActionsModel(
        label: (l10n) => l10n.transactions,
        icon:  Icon(
          Iconsax.arrow_swap,
          color: Colors.white,
          size: 28,
        ),
        color: const Color.fromARGB(255, 67, 70, 223),
      ),
    );
    actions.add(
      QuickActionsModel(
        label: (l10n) => l10n.customers,
        icon: const Icon(
          Icons.people,
          color: Colors.white,
          size: 28,
        ),
        color: const Color.fromARGB(255, 233, 192, 56),
      ),
    );
    actions.add(
      QuickActionsModel(
        label: (l10n) =>  l10n.suppliers,
        icon: const Icon(
          Icons.people,
          color: Colors.white,
          size: 28,
        ),
        color: const Color.fromARGB(255, 183, 82, 201),
      ),
    );
    actions.add(
      QuickActionsModel(
        label: (l10n) => l10n.credits,
        icon: const Icon(
          Icons.credit_card,
          color: Colors.white,
          size: 28,
        ),
        color: const Color.fromARGB(255, 255, 152, 0),
      ),
    );

    return actions;
  }
}
