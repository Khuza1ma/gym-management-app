import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_management_app/app/core/constants/storage_keys.dart';

class SharedPreferencesHelper {
  static SharedPreferencesHelper? _instance;
  static SharedPreferences? _prefs;

  SharedPreferencesHelper._();

  static Future<SharedPreferencesHelper> getInstance() async {
    _instance ??= SharedPreferencesHelper._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  String? getString(String key) {
    return _prefs!.getString(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs!.getInt(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs!.getBool(key);
  }

  Future<bool> setDouble(String key, double value) async {
    return await _prefs!.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs!.getDouble(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs!.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs!.getStringList(key);
  }

  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await _prefs!.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final String? jsonString = _prefs!.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }


  Future<bool> setThemeMode(String themeMode) async {
    return await setString(StorageKeys.themeMode, themeMode);
  }

  String getThemeMode() {
    return getString(StorageKeys.themeMode) ?? 'system';
  }

  Future<bool> setIsDarkMode(bool isDark) async {
    return await setBool(StorageKeys.isDarkMode, isDark);
  }

  bool isDarkMode() {
    return getBool(StorageKeys.isDarkMode) ?? false;
  }

  Future<bool> clearAll() async {
    try {
      await _prefs!.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeKey(String key) async {
    try {
      return await _prefs!.remove(key);
    } catch (e) {
      return false;
    }
  }

  Set<String> getAllKeys() {
    return _prefs!.getKeys();
  }

  bool containsKey(String key) {
    return _prefs!.containsKey(key);
  }
}
