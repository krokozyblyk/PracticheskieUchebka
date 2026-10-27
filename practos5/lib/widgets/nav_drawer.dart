import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../logic/permissions.dart';
import '../state/auth_notifier.dart';

class NavDrawer extends StatelessWidget {
  final String currentPath;

  const NavDrawer({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final user = auth.user;
    final role = user?.role;
    final showCustomers = role != null && role.can(Permission.manageCatalog);
    final showProfile = role != null && role.can(Permission.viewProfile);
    final showAdmin = role != null && role.can(Permission.manageUsers);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Зоомагазин',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.fullName,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      user.role.label,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _item(context, Icons.dashboard_outlined, 'Главная', '/dashboard'),
          _item(context, Icons.pets_outlined, 'Животные', '/animals'),
          _item(context, Icons.category_outlined, 'Категории', '/categories'),
          _item(
            context,
            Icons.local_shipping_outlined,
            'Поставщики',
            '/suppliers',
          ),
          _item(
            context,
            Icons.medical_services_outlined,
            'Ветеринары',
            '/vets',
          ),
          if (showCustomers)
            _item(context, Icons.people_outline, 'Покупатели', '/customers'),
          if (showProfile)
            _item(context, Icons.badge_outlined, 'Личный кабинет', '/profile'),
          if (showAdmin) ...[
            _item(
              context,
              Icons.manage_accounts_outlined,
              'Пользователи',
              '/users',
            ),
            _item(
              context,
              Icons.insights_outlined,
              'Статистика',
              '/statistics',
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Выйти'),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthNotifier>().logout(
                    message: 'Вы вышли из системы.',
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String path,
  ) {
    final selected = currentPath == path;
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selected,
      onTap: () {
        Navigator.pop(context);
        context.go(path);
      },
    );
  }
}

AppBar navAppBar(
  BuildContext context,
  String title, {
  List<Widget> actions = const [],
}) {
  final auth = context.watch<AuthNotifier>();
  final user = auth.user;
  return AppBar(
    title: Text(title),
    actions: [
      ...actions,
      if (user != null) ...[
        Center(
          child: Text(
            '${user.fullName} · ${user.role.label}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        IconButton(
          tooltip: 'Выйти',
          icon: const Icon(Icons.logout),
          onPressed: () => context.read<AuthNotifier>().logout(
                message: 'Вы вышли из системы.',
              ),
        ),
      ],
    ],
  );
}
