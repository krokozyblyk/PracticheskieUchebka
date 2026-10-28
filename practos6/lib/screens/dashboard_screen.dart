import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../logic/permissions.dart';
import '../state/auth_notifier.dart';
import '../widgets/app_navigation.dart';
import '../widgets/role_badge.dart';

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
          'Создание карточки в каталоге',
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
          Icons.groups_outlined,
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

    return AppScaffold(
      title: 'Главная',
      currentPath: '/dashboard',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Здравствуйте, ${user.fullName}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('Роль: '),
                        RoleBadge(role: user.role),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final section in sections)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 260,
                    maxWidth: 340,
                  ),
                  child: _SectionCard(section: section),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final _Section section;

  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(section.path),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  section.icon,
                  color: const Color(0xFF81C784),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                size: 18,
                color: Color(0xFF9AA0A6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
