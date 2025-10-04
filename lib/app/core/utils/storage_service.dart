import 'package:gym_management_app/app/core/utils/shared_preferences_helper.dart';

/// A service class that provides easy access to SharedPreferences operations
/// This acts as a wrapper around SharedPreferencesHelper for better organization
class StorageService {
  static StorageService? _instance;
  static SharedPreferencesHelper? _prefsHelper;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefsHelper ??= await SharedPreferencesHelper.getInstance();
    return _instance!;
  }


  Future<bool> setThemeMode(String themeMode) async {
    return await _prefsHelper!.setThemeMode(themeMode);
  }

  String getThemeMode() {
    return _prefsHelper!.getThemeMode();
  }

  Future<bool> setIsDarkMode(bool isDark) async {
    return await _prefsHelper!.setIsDarkMode(isDark);
  }

  bool isDarkMode() {
    return _prefsHelper!.isDarkMode();
  }

  Future<bool> clearAll() async {
    return await _prefsHelper!.clearAll();
  }

  Future<bool> removeKey(String key) async {
    return await _prefsHelper!.removeKey(key);
  }

  Set<String> getAllKeys() {
    return _prefsHelper!.getAllKeys();
  }

  bool containsKey(String key) {
    return _prefsHelper!.containsKey(key);
  }

  Future<bool> setString(String key, String value) async {
    return await _prefsHelper!.setString(key, value);
  }

  String? getString(String key) {
    return _prefsHelper!.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefsHelper!.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefsHelper!.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefsHelper!.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefsHelper!.getInt(key);
  }

  Future<bool> setDouble(String key, double value) async {
    return await _prefsHelper!.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefsHelper!.getDouble(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefsHelper!.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefsHelper!.getStringList(key);
  }

  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await _prefsHelper!.setJson(key, value);
  }

  Map<String, dynamic>? getJson(String key) {
    return _prefsHelper!.getJson(key);
  }
}
