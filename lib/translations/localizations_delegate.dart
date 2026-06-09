import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

import 'localizations.dart';

class LocalizationDelegate extends LocalizationsDelegate<CuacLocalization> {
  const LocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es', 'gl','pt'].contains(locale.languageCode);

  @override
  Future<CuacLocalization> load(Locale locale) async {
    // Se xa hai un CuacLocalization rexistrado co mesmo locale, reutilizámolo
    try {
      final existing = Injector.appInstance.get<CuacLocalization>();
      if (existing.locale.languageCode == locale.languageCode) {
        return existing;
      }
    } catch (_) {}
    CuacLocalization localizations = new CuacLocalization(locale);
    await localizations.load();
    Injector.appInstance.registerSingleton<CuacLocalization>(() => localizations, override: true);
    return localizations;
  }

  @override
  bool shouldReload(LocalizationDelegate old) => true;
}