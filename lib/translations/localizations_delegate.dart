import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

import 'localizations.dart';

class LocalizationDelegate extends LocalizationsDelegate<CuacLocalization> {
  const LocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es', 'gl','pt'].contains(locale.languageCode);

  @override
  Future<CuacLocalization> load(Locale locale) async {
    CuacLocalization localizations = new CuacLocalization(locale);
    Injector.appInstance.registerSingleton<CuacLocalization>((_) => localizations, override : true);
    await localizations.load();
   // localizations.loadRemote();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationDelegate old) => true;
}