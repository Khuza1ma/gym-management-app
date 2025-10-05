import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'app/controller/theme_controller.dart';
import 'app/core/theme/app_theme.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Obx(() => GetMaterialApp(
        title: 'Titan Gym',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeController.to.themeMode.value,
        getPages: AppPages.routes,
        initialRoute: AppPages.INITIAL,
      )),
    );
  }
}
