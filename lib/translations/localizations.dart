import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

abstract class CuacLocalizationContract {
  Map<String, dynamic> translateMap(String key);
  String getTranslations(String key);
  String translate(String key);
}

class CuacLocalization implements CuacLocalizationContract {

  Map<String, dynamic>? _sentencesRemote;
  Map<String, dynamic>? _sentencesLocal;
  late Locale locale;

  CuacLocalization(this.locale);

  static CuacLocalization of(BuildContext context) {
    return Localizations.of(context, CuacLocalization);
  }



  Future<bool> load() async {
    if (_sentencesLocal != null && _sentencesLocal!.isNotEmpty) {
      return true;
    } else {
      String data = await rootBundle
          .loadString('assets/translations/${this.locale.languageCode}.json');
      Map<String, dynamic> _result = json.decode(data);

      this._sentencesLocal = new Map();
      _result.forEach((String key, dynamic value) {
        this._sentencesLocal?[key] = value;
      });
      return true;
    }
  }

//  Future<bool> loadRemote() async {
//    try {
//      if (_sentencesRemote != null && _sentencesRemote.isNotEmpty) {
//        return true;
//      } else {
//        //TODO download from network translations
//        return true;
//      }
//    } catch (FormatException) {
//      return false;
//    }
//  }

  @override
  String getTranslations(String key) {
    if (_sentencesRemote != null && this._sentencesRemote!.containsKey(key)) {
      return this._sentencesRemote?[key];
    } else if (_sentencesLocal != null &&
        this._sentencesLocal!.containsKey(key)) {
      return this._sentencesLocal?[key];
    } else {
      return "";
    }
  }

  @override
  String translate(String key) {
    if (_sentencesRemote != null && this._sentencesRemote!.containsKey(key)) {
      return this._sentencesRemote?[key].toString() ?? "";
    } else if (_sentencesLocal != null &&
        this._sentencesLocal!.containsKey(key)) {
      return this._sentencesLocal?[key].toString() ?? "";
    } else {
      return "";
    }
  }

  @override
  Map<String, dynamic> translateMap(String key) {
    if (_sentencesRemote != null && this._sentencesRemote!.containsKey(key)) {
      return this._sentencesRemote?[key];
    } else if (_sentencesLocal != null &&
        this._sentencesLocal!.containsKey(key)) {
      return this._sentencesLocal?[key];
    } else {
      return Map.identity();
    }
  }
}
