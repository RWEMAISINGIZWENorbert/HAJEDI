import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final double height;
  final double sales;
  final double purchases;
  final double expenses;

  const DashboardCard({
    super.key,
    this.height = 200,
    this.sales = 0.0,
    this.purchases = 0.0,
    this.expenses = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: _cardLayer(
        sales: sales,
        purchases: purchases,
        expenses: expenses,
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5B3FE7),
            Color(0xFF4B2AD6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        opacity: 0.85,
      ),
    );
  }
}


Widget _cardLayer({
  required Color color,
  required BorderRadius borderRadius,
  Gradient? gradient,
  double opacity = 1.0,
  required double sales,
  required double purchases,
  required double expenses,
}) {
  return Opacity(
    opacity: opacity,
    child: Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? color : null,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _DashboardAmount(
              label: 'Sales',
              amount: sales,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _DashboardAmount(
                  label: 'Purchases',
                  amount: purchases,
                  textAlign: TextAlign.right,
                ),
                const Spacer(),
                _DashboardAmount(
                  label: 'Expenses',
                  amount: expenses,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _DashboardAmount extends StatelessWidget {
  final String label;
  final double amount;
  final TextAlign textAlign;

  const _DashboardAmount({
    required this.label,
    required this.amount,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: ${amount.toStringAsFixed(0)} RWF',
      textAlign: textAlign,
      softWrap: true,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
    );
  }
}