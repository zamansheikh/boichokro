import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app language and remembers the reader's choice.
///
/// Bangla is the default and is listed first wherever a language is offered.
class LocaleController extends ValueNotifier<Locale> {
  LocaleController._() : super(bangla);

  static final LocaleController instance = LocaleController._();

  static const Locale bangla = Locale('bn');
  static const Locale english = Locale('en');

  /// In the order they are offered to the reader.
  static const List<Locale> supported = [bangla, english];

  static const String _prefsKey = 'app_locale';

  /// Reads the saved choice. Call once before `runApp`.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null) {
      value = supported.firstWhere(
        (locale) => locale.languageCode == code,
        orElse: () => bangla,
      );
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale == value) return;
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}
