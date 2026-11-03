import 'package:flutter/material.dart';
import 'package:hajedi/widgets/text.dart';

class DatePeriodSelector extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DatePeriodSelector({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final highlightColor = theme.highlightColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? primaryColor.withOpacity(0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? primaryColor.withOpacity(0.4)
                : highlightColor,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: SimpleText(label: label),
      ),
    );
  }
}