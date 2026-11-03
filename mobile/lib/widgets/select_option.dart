import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hajedi/l10n/app_localizations.dart';

class SelectOption extends StatelessWidget {
  final String label;
  final ValueChanged<String?>? onSelect;
  final List<String> options;
  final String? initialValue;
  final bool isEditMode;

  const SelectOption({
    super.key, 
    required this.label, 
    required this.onSelect, 
    required this.options,
    this.initialValue,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
   return ShadTheme(
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
          primary: Theme.of(context).primaryColor,
          secondary: Colors.white,
          secondaryForeground: Colors.white,
          selection: Colors.white,
          accent: Theme.of(context).primaryColor,
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
      child: ShadSelectFormField<String>(
        onSaved: ((e) => print("The value $e")),
        onChanged: onSelect,
        id: '$label method',
        minWidth: 350,
        initialValue: isEditMode ? initialValue : null,
        options: options
            .map((m) => ShadOption(value: m, child: Text(matchTheLocalization(m, context))))
            .toList(),
        // selectedOptionBuilder: (context, value) => value == null
        //     ? Text('${l10n.select} $label')
        //     : Text(matchTheLocalization(value, context)),
        selectedOptionBuilder: (context, value) => Text(matchTheLocalization(value, context)),
        placeholder: Text(matchTheLocalization('Select the $label method', context)),
        validator: (v) {
          if (v == null) {
            return 'Please select the $label to display';
          }
          return null;
        },
      ),
    );
  }

   String matchTheLocalization(String m, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
      if(m == 'both'){ 
         return l10n.both;
      }else if(m == "unit"){
         return l10n.unit;
      }else if(m == "packet"){
        return l10n.packet;
      }else if(m == "units"){
         return l10n.units;
      }else if(m == "packets"){
         return l10n.packets;
      }else if(m == 'sack'){
         return l10n.sack;
      }else if(m == "crate"){
        return l10n.crate;
      }else if(m == "bottles"){
        return l10n.bottles;
      }
      else if(m == "Select the purchase method"){
        return l10n.select_purchase_method;
      }else if(m == "Select the sale method"){
         return l10n.select_sale_method;
      }else if(m == "Select the Role method"){
         return "${l10n.select} Role";
      }else if(m == "Select the Product type method"){
         return l10n.select_product_type_method;
      }
      else if(m == "Today"){
         return l10n.today;
      }else if(m == "This Week"){
         return l10n.this_week;
      }else if(m == "This Month"){
         return l10n.this_month;
      }else if(m == "This Year"){
         return l10n.this_year;
      }else if(m == "This Year"){
         return l10n.this_year;
      }else if(m == "All"){
         return l10n.all;
      }
      return m;
   }
}