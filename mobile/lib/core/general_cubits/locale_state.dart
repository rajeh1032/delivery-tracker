import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Immutable state encapsulating the active application [Locale].
class LocaleState extends Equatable {
  final Locale locale;

  const LocaleState(this.locale);

  bool get isArabic => locale.languageCode == 'ar';
  bool get isEnglish => locale.languageCode == 'en';

  @override
  List<Object?> get props => [locale];
}
