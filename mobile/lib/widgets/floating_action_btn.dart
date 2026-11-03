
// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class FloatingActionBtn extends StatelessWidget {
  final GestureTapCallback  onTap;
  Color? bgColor;
  Color? color;
  FloatingActionBtn({super.key, required this.onTap, this.bgColor, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        maxRadius: 28,
        backgroundColor: bgColor ?? Theme.of(context).cardColor,
        child: Center(
          child: Icon(Icons.add, color: color ?? Theme.of(context).highlightColor, size: 28,),
        ),
      ),
    );
  }
}