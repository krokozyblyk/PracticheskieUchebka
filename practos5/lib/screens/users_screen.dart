import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../core/auth_api.dart';
import '../models/app_user.dart';
import '../models/role.dart';
import '../state/auth_notifier.dart';
import '../widgets/api_error.dart';
import '../widgets/nav_drawer.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<AppUser> _users = [];
  bool _loading = true;
  String? _error;
  final Set<int> _saving = {};

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
      final users = await context.read<AuthApi>().users();
      if (!mounted) return;
      setState(() {
        _users = users;
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

  Future<void> _changeRole(AppUser user, Role role) async {
    if (_saving.contains(user.id)) return;
    setState(() => _saving.add(user.id));
    try {
      final updated = await context.read<AuthApi>().updateRole(user.id, role);
      if (!mounted) return;
      setState(() {
        _users = _users
            .map((item) => item.id == updated.id ? updated : item)
            .toList();
      });
    } on ApiException catch (error) {
      if (mounted) showApiError(context, error);
    } finally {
      if (mounted) setState(() => _saving.remove(user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navAppBar(context, 'Пользователи'),
      drawer: const NavDrawer(currentPath: '/users'),
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

    final current = context.watch<AuthNotifier>().user;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final user = _users[index];
        final self = user.id == current?.id;
        return ListTile(
          leading: CircleAvatar(
            child: Text(user.fullName.isEmpty ? '?' : user.fullName[0]),
          ),
          title: Text(user.fullName),
          subtitle: Text('${user.username} · ${user.email}'),
          trailing: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_saving.contains(user.id))
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                DropdownButton<Role>(
                  value: user.role,
                  onChanged: self
                      ? null
                      : (role) {
                          if (role != null) _changeRole(user, role);
                        },
                  items: [
                    for (final role in Role.values)
                      DropdownMenuItem(
                        value: role,
                        child: Text(role.label),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
