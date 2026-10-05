import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme and language, kept on this phone.
class Prefs {
  const Prefs({this.theme = ThemeMode.system, this.locale});
  final ThemeMode theme;
  final Locale? locale; // null follows the phone

  Prefs copyWith({ThemeMode? theme, Locale? locale, bool clearLocale = false}) =>
      Prefs(theme: theme ?? this.theme, locale: clearLocale ? null : (locale ?? this.locale));
}

class PrefsNotifier extends Notifier<Prefs> {
  @override
  Prefs build() {
    _load();
    return const Prefs();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final theme = ThemeMode.values.firstWhere((m) => m.name == p.getString('theme'), orElse: () => ThemeMode.system);
    final lang = p.getString('lang');
    state = Prefs(theme: theme, locale: lang == null ? null : Locale(lang));
  }

  Future<void> setTheme(ThemeMode m) async {
    state = state.copyWith(theme: m);
    await (await SharedPreferences.getInstance()).setString('theme', m.name);
  }

  Future<void> setLocale(Locale? l) async {
    state = l == null ? state.copyWith(clearLocale: true) : state.copyWith(locale: l);
    final p = await SharedPreferences.getInstance();
    if (l == null) {
      await p.remove('lang');
    } else {
      await p.setString('lang', l.languageCode);
    }
  }
}

final prefsProvider = NotifierProvider<PrefsNotifier, Prefs>(PrefsNotifier.new);
