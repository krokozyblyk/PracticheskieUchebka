import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../core/auth_api.dart';
import '../widgets/api_error.dart';
import '../widgets/app_navigation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileResult? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await context.read<AuthApi>().profile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
      showApiError(context, error);
    }
  }

  String _date(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Личный кабинет',
      currentPath: '/profile',
      maxWidth: 900,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    final profile = _profile!;
    final customer = profile.customer;
    final card = customer?.loyaltyCard;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _card('Учётная запись', [
          _row('Логин', profile.user.username),
          _row('ФИО', profile.user.fullName),
          _row('Почта', profile.user.email),
          _row('Роль', profile.user.role.label),
        ]),
        if (customer != null) ...[
          const SizedBox(height: 12),
          _card('Данные покупателя', [
            _row('ФИО', customer.fullName),
            _row('Почта', customer.email),
            _row('Телефон', customer.phone),
            _row('Адрес', customer.address),
          ]),
        ],
        if (card != null) ...[
          const SizedBox(height: 12),
          _card('Карта лояльности', [
            _row('Номер', card.cardNumber),
            _row('Дата выдачи', _date(card.issuedAt)),
            _row('Скидка', '${card.discountPercent}%'),
            _row('Активна', card.active ? 'да' : 'нет'),
          ]),
        ],
      ],
    );
  }

  Widget _card(String title, List<Widget> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 480;
        final labelWidget = Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF9AA0A6),
            fontSize: 12,
          ),
        );
        final valueWidget = Text(value);
        if (narrow) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [labelWidget, const SizedBox(height: 2), valueWidget],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 160, child: labelWidget),
              Expanded(child: valueWidget),
            ],
          ),
        );
      },
    );
  }
}
