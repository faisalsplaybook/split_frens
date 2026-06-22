import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// Settings Service
// ==========================================
class SettingsService {
  static const String _defaultCurrencyKey = 'default_currency';
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String getDefaultCurrency() {
    return _prefs.getString(_defaultCurrencyKey) ?? 'USD';
  }

  static Future<void> setDefaultCurrency(String currency) async {
    await _prefs.setString(_defaultCurrencyKey, currency);
  }
}
