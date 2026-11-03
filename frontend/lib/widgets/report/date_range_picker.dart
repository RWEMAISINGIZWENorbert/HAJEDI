import 'package:flutter/material.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/text.dart';
import 'package:intl/intl.dart';

class DateRangePicker extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;

  const DateRangePicker({
    super.key,
    this.startDate,
    this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  Future<void> _pickDate(
    BuildContext context,
    DateTime? current,
    ValueChanged<DateTime?> onChanged,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: const Color(0xFF1F2937),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final highlightColor = theme.highlightColor;

    return Center(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Start Date
          GestureDetector(
            onTap: () => _pickDate(context, startDate, onStartDateChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: startDate != null
                    ? primaryColor.withOpacity(0.02)
                    : Colors.transparent,
                border: Border.all(
                  color: startDate != null
                      ? primaryColor.withOpacity(0.04)
                      : highlightColor,
                  width: startDate != null ? 2.0 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SimpleText(label: "Start Date"),
                  const SizedBox(height: 4),
                  Text(
                    startDate != null
                        ? DateFormat('MMM d, yyyy').format(startDate!)
                        : "Select Date",
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: startDate != null ? null : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // End Date
          GestureDetector(
            onTap: () => _pickDate(context, endDate, onEndDateChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: endDate != null
                    ? primaryColor.withOpacity(0.02)
                    : Colors.transparent,
                border: Border.all(
                  color: endDate != null
                      ? primaryColor.withOpacity(0.04)
                      : highlightColor,
                  width: endDate != null ? 2.0 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SimpleText(label: "End Date"),
                  const SizedBox(height: 4),
                  Text(
                    endDate != null
                        ? DateFormat('MMM d, yyyy').format(endDate!)
                        : "Select Date",
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: endDate != null ? null : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}