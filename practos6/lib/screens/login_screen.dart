import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../logic/validators.dart';
import '../state/auth_notifier.dart';
import '../widgets/auth_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;
  Map<String, String> _fieldErrors = const {};

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _error = null;
      _fieldErrors = const {};
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthNotifier>();
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    setState(() => _busy = true);
    try {
      await auth.login(_username.text, _password.text);
      if (!mounted) return;
      final requested = from != null && from.isNotEmpty ? from : '/dashboard';
      final target = auth.canOpen(requested) ? requested : '/dashboard';
      context.go(target);
    } on ValidationException catch (error) {
      if (mounted) setState(() => _fieldErrors = error.errors);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final message = auth.message;

    return AuthScaffold(
      register: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Вход в систему',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            const Text(
              'Введите логин и пароль учебной учётной записи.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9AA0A6)),
            ),
            const SizedBox(height: 20),
            if (message != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF93000A).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEF9A9A)),
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Color(0xFFFFDAD6)),
                ),
              ),
              const SizedBox(height: 14),
            ],
            TextFormField(
              controller: _username,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Логин',
                errorText: _fieldErrors['username'],
              ),
              validator: (value) => requiredValidator(value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Пароль',
                errorText: _fieldErrors['password'],
              ),
              validator: (value) => requiredValidator(value),
            ),
            const SizedBox(height: 14),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ),
            FilledButton.icon(
              onPressed: _busy ? null : _submit,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login),
              label: const Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }
}
