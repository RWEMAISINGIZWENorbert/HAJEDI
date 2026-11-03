import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class LocaleCubit extends HydratedCubit<Locale?> {
  LocaleCubit() : super(null); // null => follow system locale

  void setLocale(Locale locale) => emit(locale);

  void useSystemLocale() => emit(null);

  @override
  Locale? fromJson(Map<String, dynamic> json) {
    final code = json['languageCode'] as String?;
    final country = json['countryCode'] as String?;
    if (code == null) return null;
    return country != null && country.isNotEmpty ? Locale(code, country) : Locale(code);
  }

  @override
  Map<String, dynamic>? toJson(Locale? state) {
    if (state == null) return {};
    return {
      'languageCode': state.languageCode,
      'countryCode': state.countryCode,
    };
  }
}
