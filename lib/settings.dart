import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n.dart';

class AppSettings extends ChangeNotifier {
  late SharedPreferences _p;

  int focusMin = 25;
  int shortBreakMin = 5;
  int longBreakMin = 15;
  int sessionsBeforeLong = 4;
  int dailyGoal = 4;
  bool autoStartBreak = true;
  bool scanEnabled = true;
  bool vibrate = true;
  bool showTip = true;
  bool notifyEnabled = true;
  double minConfidence = 0.5;
  ThemeMode themeMode = ThemeMode.system;
  AppLang lang = AppLang.en;

  L10n get l => L10n(lang);

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    focusMin = _p.getInt('focusMin') ?? 25;
    shortBreakMin = _p.getInt('shortBreakMin') ?? 5;
    longBreakMin = _p.getInt('longBreakMin') ?? 15;
    sessionsBeforeLong = _p.getInt('sessionsBeforeLong') ?? 4;
    dailyGoal = _p.getInt('dailyGoal') ?? 4;
    autoStartBreak = _p.getBool('autoStartBreak') ?? true;
    scanEnabled = _p.getBool('scanEnabled') ?? true;
    vibrate = _p.getBool('vibrate') ?? true;
    showTip = _p.getBool('showTip') ?? true;
    notifyEnabled = _p.getBool('notify') ?? true;
    minConfidence = _p.getDouble('minConfidence') ?? 0.5;
    themeMode = ThemeMode.values[_p.getInt('theme') ?? 0];

    // First launch: follow the phone's language (Turkish or English).
    final saved = _p.getInt('lang');
    lang = saved != null
        ? AppLang.values[saved]
        : (ui.PlatformDispatcher.instance.locale.languageCode == 'tr'
            ? AppLang.tr
            : AppLang.en);
  }

  /// Apply a change, save it and notify listeners.
  void set(void Function() change) {
    change();
    _p.setInt('focusMin', focusMin);
    _p.setInt('shortBreakMin', shortBreakMin);
    _p.setInt('longBreakMin', longBreakMin);
    _p.setInt('sessionsBeforeLong', sessionsBeforeLong);
    _p.setInt('dailyGoal', dailyGoal);
    _p.setBool('autoStartBreak', autoStartBreak);
    _p.setBool('scanEnabled', scanEnabled);
    _p.setBool('vibrate', vibrate);
    _p.setBool('showTip', showTip);
    _p.setBool('notify', notifyEnabled);
    _p.setDouble('minConfidence', minConfidence);
    _p.setInt('theme', themeMode.index);
    _p.setInt('lang', lang.index);
    notifyListeners();
  }
}