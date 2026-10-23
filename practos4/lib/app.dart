import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class ZooApp extends StatelessWidget {
  const ZooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Зоомагазин',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(brightness: Brightness.light),
      darkTheme: buildAppTheme(brightness: Brightness.dark),
      routerConfig: appRouter,
    );
  }
}
