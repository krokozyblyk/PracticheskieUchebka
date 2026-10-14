import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'router.dart';
import 'theme.dart';

class PractosApp extends StatelessWidget {
  const PractosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Калькулятор и конвертер валют',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(brightness: Brightness.light),
          darkTheme: buildAppTheme(brightness: Brightness.dark),
          themeMode: AppSettings.instance.themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
