import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';

class LocaleProvider extends ChangeNotifier {
  String _localeCode = AppStrings.initialLocale;

  String get localeCode => _localeCode;

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('appLocale');
    if (saved != null && AppStrings.supportedLocales.contains(saved)) {
      _localeCode = saved;
    } else {
      _localeCode = AppStrings.initialLocale;
    }
    AppStrings.setLocale(_localeCode);
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    if (!AppStrings.supportedLocales.contains(code)) return;
    _localeCode = code;
    AppStrings.setLocale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appLocale', code);
    notifyListeners();
  }
}
