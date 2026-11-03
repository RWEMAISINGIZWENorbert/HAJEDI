import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ThemeType { light, dark }

class ThemeState extends Equatable {
  // final ThemeType themeType;
  // final ThemeData themeData;
  final ThemeMode themeMode;

  const ThemeState({
    // required this.themeType,
    // required this.themeData,
    required this.themeMode,
  });

  @override
  List<Object> get props => [themeMode];

  ThemeState copyWith({
    // ThemeType? themeType,
    // ThemeData? themeData,
    ThemeMode? themeMode,
  }) {
    return ThemeState(
      // themeType: themeType ?? this.themeType,
      // themeData: themeData ?? this.themeData,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}