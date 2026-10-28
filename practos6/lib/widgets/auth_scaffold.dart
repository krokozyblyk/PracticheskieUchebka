import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/role.dart';
import 'role_badge.dart';

class AuthScaffold extends StatelessWidget {
  final bool register;
  final Widget child;

  const AuthScaffold({super.key, required this.register, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (width < 1000) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.pets, color: Color(0xFF81C784), size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Зоомагазин',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
            _AuthTabs(register: register),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );

    if (width >= 1000) {
      return Scaffold(
        body: Row(
          children: [
            const Expanded(flex: 5, child: _BrandPanel()),
            Expanded(
              flex: 4,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: card,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: card,
          ),
        ),
      ),
    );
  }
}

class _AuthTabs extends StatelessWidget {
  final bool register;

  const _AuthTabs({required this.register});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _tab(context, 'Вход', !register, '/login'),
        const SizedBox(width: 20),
        _tab(context, 'Регистрация', register, '/register'),
      ],
    );
  }

  Widget _tab(BuildContext context, String label, bool active, String path) {
    return Expanded(
      child: InkWell(
        onTap: active ? null : () => context.go(path),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? const Color(0xFF81C784) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? const Color(0xFFE8EAED) : const Color(0xFF9AA0A6),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1A0E), Color(0xFF121212)],
        ),
      ),
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.pets, color: Color(0xFF81C784), size: 34),
              SizedBox(width: 12),
              Text(
                'Зоомагазин',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            'Система учёта\nи каталог магазина',
            style: TextStyle(
              fontSize: 32,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Каталог животных, справочники, карты лояльности и разграничение '
            'доступа по ролям — в одном рабочем месте.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF9AA0A6),
            ),
          ),
          const SizedBox(height: 32),
          _roleRow(Role.customer, 'Просмотр каталога и личный кабинет'),
          _roleRow(Role.specialist, 'Создание и изменение карточек каталога'),
          _roleRow(Role.admin, 'Пользователи, статистика, восстановление'),
          const Spacer(),
          const Text(
            'Material 3 · Dark · ZooShop',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.4,
              color: Color(0xFF5F6368),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleRow(Role role, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          RoleBadge(role: role),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFFBFCABA)),
            ),
          ),
        ],
      ),
    );
  }
}
