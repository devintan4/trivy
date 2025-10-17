import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends Notifier<bool> {
  late SharedPreferences _prefs;
  static const _expertModeKey = 'expertMode';

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    state = _prefs.getBool(_expertModeKey) ?? false;
  }

  @override
  bool build() {
    _init();
    return false;
  }

  Future<void> setExpertMode(bool isExpert) async {
    state = isExpert;
    await _prefs.setBool(_expertModeKey, isExpert);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, bool>(
  SettingsNotifier.new,
);
