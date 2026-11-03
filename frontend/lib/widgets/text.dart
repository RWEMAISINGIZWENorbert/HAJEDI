import 'package:flutter/material.dart';

class SimpleText extends StatelessWidget {
  final String label; 
  final Color? color;
  const SimpleText({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6), 
      child: Text(label, style: Theme.of(context).textTheme.displayMedium!.copyWith(color: color),)
      );
  }
}