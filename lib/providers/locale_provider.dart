import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

class LocaleProvider with ChangeNotifier {
  static const supportedLanguageCodes = ['en', 'it'];

  final StorageService _storageService = StorageService();

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final savedCode = await _storageService.loadLanguageCode();
    if (savedCode != null && supportedLanguageCodes.contains(savedCode)) {
      _locale = Locale(savedCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLanguageCodes.contains(locale.languageCode)) return;
    _locale = locale;
    await _storageService.saveLanguageCode(locale.languageCode);
    notifyListeners();
  }

  Future<void> clearLocale() async {
    _locale = const Locale('en');
    await _storageService.clearLanguageCode();
    notifyListeners();
  }
}
