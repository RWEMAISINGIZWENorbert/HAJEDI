import 'package:flutter/material.dart';
import 'package:hajedi/bloc/theme/theme_event.dart';
import 'package:hajedi/bloc/theme/theme_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  // ThemeBloc() : super(ThemeState(themeType: ThemeType.dark, themeData: darkTheme)) {
  ThemeBloc() : super(const ThemeState(themeMode: ThemeMode.system)) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<LoadThemeEvent>(_onLoadTheme);
  }

  void _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) {
    // if (state.themeType == ThemeType.dark) {
    //   emit(state.copyWith(themeType: ThemeType.light, themeData: lightTheme));
    // } else {
    //   emit(state.copyWith(themeType: ThemeType.dark, themeData: darkTheme));
    // }
    final currentMode = state.themeMode;
    final nextMode = currentMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(state.copyWith(themeMode: nextMode));
  }

  void _onLoadTheme(LoadThemeEvent event, Emitter<ThemeState> emit) {
    // This is handled by hydrated bloc
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    try {
      // final themeType = ThemeType.values.byName(json['themeType'] as String);
      // return ThemeState(
      //   themeType: themeType,
      //   themeData: themeType == ThemeType.dark ? darkTheme : lightTheme,
      // );
      final themeMode = ThemeMode.values.byName(json['themeMode'] as String);
      return ThemeState(themeMode: themeMode);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    return {
      // 'themeType': state.themeType.name,
      'themeMode': state.themeMode.name,
    };
  }
}