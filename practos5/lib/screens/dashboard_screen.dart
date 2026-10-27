import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../logic/permissions.dart';
import '../state/auth_notifier.dart';
import '../widgets/nav_drawer.dart';

class _Section {
  final IconData icon;
  final String title;
  final String subtitle;
  final String path;

  const _Section(this.icon, this.title, this.subtitle, this.path);
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final sections = <_Section>[
      const _Section(
        Icons.pets_outlined,
        'Каталог животных',
        'Просмотр списка, поиск и фильтры',
        '/animals',
      ),
      if (user.role.can(Permission.viewProfile))
        const _Section(
          Icons.badge_outlined,
          'Личный кабинет',
          'Мои данные и карта лояльности',
          '/profile',
        ),
      if (user.role.can(Permission.manageCatalog)) ...[
        const _Section(
          Icons.add_circle_outline,
          'Новое животное',
          'Создание записи в каталоге',
          '/animals/new',
        ),
        const _Section(
          Icons.category_outlined,
          'Категории',
          'Управление справочником',
          '/categories',
        ),
        const _Section(
          Icons.local_shipping_outlined,
          'Поставщики',
          'Управление справочником',
          '/suppliers',
        ),
        const _Section(
          Icons.medical_services_outlined,
          'Ветеринары',
          'Управление справочником',
          '/vets',
        ),
        const _Section(
          Icons.people_outline,
          'Покупатели',
          'Карты лояльности и контакты',
          '/customers',
        ),
      ],
      if (user.role.can(Permission.manageUsers)) ...[
        const _Section(
          Icons.manage_accounts_outlined,
          'Пользователи',
          'Роли и доступы',
          '/users',
        ),
        const _Section(
          Icons.insights_outlined,
          'Статистика',
          'Сводка по данным каталога',
          '/statistics',
        ),
      ],
    ];

    return Scaffold(
      appBar: navAppBar(context, 'Главная'),
      drawer: const NavDrawer(currentPath: '/dashboard'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Здравствуйте, ${user.fullName}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text('Роль: ${user.role.label}'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final section in sections)
                SizedBox(
                  width: 280,
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.go(section.path),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(section.icon, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    section.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(section.subtitle),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
