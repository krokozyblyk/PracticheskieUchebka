import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_notifier.dart';

class SessionWarningHost extends StatelessWidget {
  final Widget child;

  const SessionWarningHost({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    if (!auth.warningVisible) return child;

    final seconds = auth.warningRemaining.inSeconds;
    return Stack(
      children: [
        child,
        const ModalBarrier(dismissible: false, color: Colors.black54),
        Center(
          child: Material(
            type: MaterialType.transparency,
            child: AlertDialog(
              title: const Text('Сессия завершается'),
              content: Text(
                'Из-за бездействия сессия закроется через $seconds с. '
                'Нажмите «Продолжить», чтобы остаться в системе.',
              ),
              actions: [
                TextButton(
                  onPressed: () => auth.logout(
                    message: 'Сессия завершена из-за неактивности.',
                  ),
                  child: const Text('Выйти'),
                ),
                FilledButton(
                  onPressed: auth.touch,
                  child: const Text('Продолжить'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
