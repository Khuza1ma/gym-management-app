import 'package:gym_management_app/app/core/utils/storage_service.dart';
import 'package:gym_management_app/app/core/constants/storage_keys.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ThemeController to manage the theme mode of the application.
class ThemeController extends GetxController with WidgetsBindingObserver {
  /// Get the ThemeController instance
  static ThemeController get to => Get.find<ThemeController>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialTheme();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setIsDarkMode();
  }

  /// 0: system, 1: light, 2: dark
  /// Initial theme mode is determined by the stored value in LocalStore.
  final Rx<ThemeMode> themeMode = _getInitialThemeMode().obs;

  /// Reactive boolean to indicate if dark mode is enabled.
  /// Either set by the theme mode or due to system settings.
  final RxBool isDarkMode = false.obs;

  static ThemeMode _getInitialThemeMode() {
    return ThemeMode.system;
  }

  Future<void> _loadInitialTheme() async {
    final storage = await StorageService.getInstance();
    final stored = storage.getInt(StorageKeys.themeMode);
    switch (stored) {
      case 1:
        themeMode.value = ThemeMode.light;
        break;
      case 2:
        themeMode.value = ThemeMode.dark;
        break;
      case 0:
      default:
        themeMode.value = ThemeMode.system;
    }
    setIsDarkMode();
  }

  /// Toggles the theme mode between light and dark.
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    int modeInt = 0;
    if (mode == ThemeMode.light) modeInt = 1;
    if (mode == ThemeMode.dark) modeInt = 2;
    StorageService.getInstance().then(
      (s) => s.setInt(StorageKeys.themeMode, modeInt),
    );
    setIsDarkMode();
  }

  /// Toggles the theme mode based on the current mode.
  void setIsDarkMode() {
    final Brightness brightness = themeMode() == ThemeMode.system
        ? WidgetsBinding.instance.platformDispatcher.platformBrightness
        : (themeMode() == ThemeMode.light ? Brightness.light : Brightness.dark);

    isDarkMode(brightness == Brightness.dark);
  }
}
