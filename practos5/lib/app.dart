import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'router.dart';
import 'state/auth_notifier.dart';
import 'theme.dart';
import 'widgets/inactivity_watcher.dart';
import 'widgets/session_warning_host.dart';

class ZooApp extends StatefulWidget {
  const ZooApp({super.key});

  @override
  State<ZooApp> createState() => _ZooAppState();
}

class _ZooAppState extends State<ZooApp> {
  late final AuthNotifier _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthNotifier>();
    _router = buildRouter(_auth);
  }

  @override
  Widget build(BuildContext context) {
    return InactivityWatcher(
      onActivity: _auth.touch,
      child: MaterialApp.router(
        title: 'Зоомагазин',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(brightness: Brightness.light),
        darkTheme: buildAppTheme(brightness: Brightness.dark),
        routerConfig: _router,
        builder: (context, child) =>
            SessionWarningHost(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
