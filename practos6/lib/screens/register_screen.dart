import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../core/auth_api.dart';
import '../logic/validators.dart';
import '../widgets/auth_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;
  Map<String, String> _fieldErrors = const {};

  @override
  void initState() {
    super.initState();
    _password.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _password.removeListener(_onPasswordChanged);
    _username.dispose();
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _onPasswordChanged() => setState(() {});

  bool get _hasLength => _password.text.length >= 8;
  bool get _hasDigit => RegExp(r'\d').hasMatch(_password.text);
  bool get _hasSpecial => RegExp(r'[^A-Za-z0-9]').hasMatch(_password.text);

  String? _validatePassword(String? value) {
    final required = requiredValidator(value);
    if (required != null) return required;
    if (!_hasLength) return 'Минимум 8 символов';
    if (!_hasDigit) return 'Добавьте цифру';
    if (!_hasSpecial) return 'Добавьте специальный символ';
    return null;
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _error = null;
      _fieldErrors = const {};
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _busy = true);
    try {
      await context.read<AuthApi>().register(
        username: _username.text,
        password: _password.text,
        fullName: _fullName.text,
        email: _email.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Регистрация завершена. Войдите в систему.'),
        ),
      );
      context.go('/login');
    } on ValidationException catch (error) {
      if (mounted) setState(() => _fieldErrors = error.errors);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _rule(String text, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: done ? const Color(0xFF81C784) : const Color(0xFF5F6368),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: done ? const Color(0xFFBFCABA) : const Color(0xFF9AA0A6),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      register: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Регистрация',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            const Text(
              'Новая учётная запись получит роль покупателя.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9AA0A6)),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _username,
              decoration: InputDecoration(
                labelText: 'Логин',
                errorText: _fieldErrors['username'],
              ),
              validator: (value) => combineValidators([
                (value) => requiredValidator(value),
                lengthValidator(3, 30),
              ])(value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fullName,
              decoration: InputDecoration(
                labelText: 'ФИО',
                errorText: _fieldErrors['fullName'],
              ),
              validator: (value) => combineValidators([
                (value) => requiredValidator(value),
                lengthValidator(3, 60),
              ])(value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Почта',
                errorText: _fieldErrors['email'],
              ),
              validator: (value) => combineValidators([
                (value) => requiredValidator(value),
                emailValidator,
              ])(value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Пароль',
                errorText: _fieldErrors['password'],
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 8),
            _rule('Не менее 8 символов', _hasLength),
            _rule('Содержит цифру', _hasDigit),
            _rule('Содержит специальный символ', _hasSpecial),
            const SizedBox(height: 10),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Повторите пароль'),
              validator: (value) =>
                  value == _password.text ? null : 'Пароли не совпадают',
            ),
            const SizedBox(height: 16),
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
                  : const Icon(Icons.person_add_alt),
              label: const Text('Создать аккаунт'),
            ),
          ],
        ),
      ),
    );
  }
}
