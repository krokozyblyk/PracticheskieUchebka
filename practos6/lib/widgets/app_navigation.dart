import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../logic/permissions.dart';
import '../models/role.dart';
import '../state/auth_notifier.dart';
import 'role_badge.dart';

class NavItem {
  final String label;
  final IconData icon;
  final String path;

  const NavItem(this.label, this.icon, this.path);
}

List<NavItem> navItemsFor(Role role) {
  return [
    const NavItem('Главная', Icons.dashboard_outlined, '/dashboard'),
    const NavItem('Каталог животных', Icons.pets_outlined, '/animals'),
    const NavItem('Категории', Icons.category_outlined, '/categories'),
    const NavItem('Поставщики', Icons.local_shipping_outlined, '/suppliers'),
    const NavItem('Ветеринары', Icons.medical_services_outlined, '/vets'),
    if (role.can(Permission.manageOrders))
      const NavItem('Заказы', Icons.shopping_cart_outlined, '/orders'),
    if (role.can(Permission.manageAppointments))
      const NavItem('Записи', Icons.event_available_outlined, '/appointments'),
    if (role.can(Permission.manageReviews))
      const NavItem('Мои отзывы', Icons.star_outline, '/reviews'),
    if (role.can(Permission.manageCatalog))
      const NavItem('Покупатели', Icons.groups_outlined, '/customers'),
    if (role.can(Permission.viewProfile))
      const NavItem('Личный кабинет', Icons.badge_outlined, '/profile'),
    if (role.can(Permission.manageUsers)) ...[
      const NavItem('Пользователи', Icons.manage_accounts_outlined, '/users'),
      const NavItem('Статистика', Icons.insights_outlined, '/statistics'),
    ],
  ];
}

class AppScaffold extends StatelessWidget {
  final String title;
  final String currentPath;
  final Widget body;
  final List<Widget> actions;
  final Widget? leading;
  final bool showNavigation;
  final double maxWidth;

  const AppScaffold({
    super.key,
    required this.title,
    required this.currentPath,
    required this.body,
    this.actions = const [],
    this.leading,
    this.showNavigation = true,
    this.maxWidth = 1440,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final width = MediaQuery.sizeOf(context).width;
    final user = auth.user;

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final targetWidth = constraints.maxWidth > maxWidth
            ? maxWidth
            : constraints.maxWidth;
        return Center(
          child: SizedBox(
            width: targetWidth,
            height: constraints.maxHeight,
            child: body,
          ),
        );
      },
    );

    if (!showNavigation || user == null) {
      return Scaffold(
        appBar: _appBar(context, auth, width),
        body: SafeArea(child: content),
      );
    }

    if (width < 720) {
      final items = navItemsFor(user.role);
      final primary = items.take(3).toList();
      final selected = items.indexWhere((item) => item.path == currentPath);
      final moreSelected = selected >= primary.length;
      return Scaffold(
        appBar: _appBar(context, auth, width),
        body: SafeArea(child: content),
        bottomNavigationBar: NavigationBar(
          selectedIndex: moreSelected ? primary.length : selected,
          onDestinationSelected: (index) {
            if (index == primary.length) {
              _showMore(context, auth, items);
            } else {
              context.go(primary[index].path);
            }
          },
          destinations: [
            for (final item in primary)
              NavigationDestination(icon: Icon(item.icon), label: item.label),
            const NavigationDestination(
              icon: Icon(Icons.more_horiz),
              label: 'Ещё',
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: _appBar(context, auth, width),
      body: SafeArea(
        child: Row(
          children: [
            _SideNavigation(
              extended: width >= 1200,
              currentPath: currentPath,
              auth: auth,
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context, AuthNotifier auth, double width) {
    final user = auth.user;
    return AppBar(
      leading: leading,
      title: Text(title),
      actions: [
        ...actions,
        if (user != null) ...[
          if (width >= 900)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                user.fullName,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9AA0A6)),
              ),
            ),
          if (width >= 520)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: RoleBadge(role: user.role, dense: true),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message: '${user.fullName} ? ${user.role.label}',
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: roleColor(user.role).withValues(alpha: 0.2),
                  child: Text(
                    user.fullName.isEmpty ? '?' : user.fullName[0],
                    style: TextStyle(fontSize: 12, color: roleColor(user.role)),
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Выйти',
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(message: 'Вы вышли из системы.'),
          ),
        ],
      ],
    );
  }

  void _showMore(BuildContext context, AuthNotifier auth, List<NavItem> items) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF242424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final user = auth.user;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5F6368),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (user != null)
                ListTile(
                  title: Text(user.fullName),
                  subtitle: Text(user.role.label),
                  trailing: RoleBadge(role: user.role, dense: true),
                ),
              const Divider(),
              for (final item in items)
                ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.label),
                  selected: item.path == currentPath,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(item.path);
                  },
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Выйти'),
                onTap: () {
                  Navigator.pop(context);
                  auth.logout(message: 'Вы вышли из системы.');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SideNavigation extends StatelessWidget {
  final bool extended;
  final String currentPath;
  final AuthNotifier auth;

  const _SideNavigation({
    required this.extended,
    required this.currentPath,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();
    final items = navItemsFor(user.role);

    return Container(
      width: extended ? 240 : 72,
      color: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              extended ? 18 : 0,
              20,
              extended ? 18 : 0,
              18,
            ),
            child: extended
                ? Row(
                    children: [
                      const Icon(
                        Icons.pets,
                        color: Color(0xFF81C784),
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Зоомагазин',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Система учёта',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.4,
                              color: Color(0xFF9AA0A6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const Icon(Icons.pets, color: Color(0xFF81C784), size: 26),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Column(
                children: [
                  for (final item in items)
                    _NavTile(
                      item: item,
                      selected: item.path == currentPath,
                      extended: extended,
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: extended
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: roleColor(
                              user.role,
                            ).withValues(alpha: 0.2),
                            child: Text(
                              user.fullName.isEmpty ? '?' : user.fullName[0],
                              style: TextStyle(
                                color: roleColor(user.role),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                RoleBadge(role: user.role, dense: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              auth.logout(message: 'Вы вышли из системы.'),
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Выйти'),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: roleColor(
                          user.role,
                        ).withValues(alpha: 0.2),
                        child: Text(
                          user.fullName.isEmpty ? '?' : user.fullName[0],
                          style: TextStyle(
                            color: roleColor(user.role),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        tooltip: 'Выйти',
                        onPressed: () =>
                            auth.logout(message: 'Вы вышли из системы.'),
                        icon: const Icon(Icons.logout, size: 20),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final NavItem item;
  final bool selected;
  final bool extended;

  const _NavTile({
    required this.item,
    required this.selected,
    required this.extended,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF81C784) : const Color(0xFF9AA0A6);
    final tile = Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2A3D2B) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.go(item.path),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: extended ? 12 : 0,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment: extended
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 22, color: color),
              if (extended) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      color: selected
                          ? const Color(0xFFE8EAED)
                          : const Color(0xFFBFCABA),
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return extended ? tile : Tooltip(message: item.label, child: tile);
  }
}
