import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_exceptions.dart';
import '../core/auth_api.dart';
import '../core/config.dart';
import '../logic/permissions.dart';
import '../logic/session_rules.dart';
import '../models/app_user.dart';
import '../models/role.dart';

class AuthNotifier extends ChangeNotifier {
  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';
  static const _kUser = 'auth_user';
  static const _kActivity = 'auth_last_activity';
  static const _kLoginAt = 'auth_login_at';

  final SharedPreferences _prefs;
  final AuthApi _api;

  AuthNotifier(this._prefs, this._api)
      : rules = SessionRules(
          idle: Duration(seconds: sessionIdleSeconds),
          warning: Duration(seconds: sessionWarningSeconds),
          max: Duration(seconds: sessionMaxSeconds),
        );

  final SessionRules rules;

  AppUser? _user;
  String? _accessToken;
  String? _refreshToken;
  DateTime? _lastActivity;
  DateTime? _loginAt;
  DateTime? _lastPersist;
  Timer? _ticker;
  Future<bool>? _refreshing;
  bool _warningVisible = false;
  Duration _warningRemaining = Duration.zero;
  String? _message;

  AppUser? get user => _user;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _user != null && _accessToken != null;
  bool get isAdmin => _user?.role == Role.admin;
  String? get message => _message;
  bool get warningVisible => _warningVisible;
  Duration get warningRemaining => _warningRemaining;

  bool can(Permission permission) =>
      _user != null && _user!.role.can(permission);

  bool canOpen(String path) {
    final current = _user;
    if (current == null) return false;
    return canOpenPath(current.role, path);
  }

  Future<void> restore() async {
    _accessToken = _prefs.getString(_kAccess);
    _refreshToken = _prefs.getString(_kRefresh);
    _lastActivity = DateTime.tryParse(_prefs.getString(_kActivity) ?? '');
    _loginAt = DateTime.tryParse(_prefs.getString(_kLoginAt) ?? '');

    final rawUser = _prefs.getString(_kUser);
    if (rawUser != null) {
      try {
        _user = AppUser.fromJson(
          Map<String, dynamic>.from(jsonDecode(rawUser) as Map),
        );
      } catch (_) {
        _user = null;
      }
    }

    if (_user == null || _accessToken == null) {
      await _clearLocal();
      return;
    }

    final now = DateTime.now();
    if (_loginAt == null || rules.maxExpired(now.difference(_loginAt!))) {
      await _expire('Сессия истекла. Войдите снова.');
      return;
    }
    if (_lastActivity == null ||
        rules.idleExpired(now.difference(_lastActivity!))) {
      await _expire('Сессия завершена из-за неактивности.');
      return;
    }

    _startTicker();
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final result = await _api.login(username, password);
    _accessToken = result.accessToken;
    _refreshToken = result.refreshToken;
    _user = result.user;
    _lastActivity = DateTime.now();
    _loginAt = _lastActivity;
    _warningVisible = false;
    _warningRemaining = Duration.zero;
    _message = null;
    await _persistSession();
    _startTicker();
    notifyListeners();
  }

  Future<bool> refreshTokens() {
    final pending = _refreshing;
    if (pending != null) return pending;
    final future = _refreshInternal();
    _refreshing = future;
    future.whenComplete(() {
      if (identical(_refreshing, future)) _refreshing = null;
    });
    return future;
  }

  Future<bool> _refreshInternal() async {
    final token = _refreshToken;
    if (token == null) return false;
    try {
      final result = await _api.refresh(token);
      _accessToken = result.accessToken;
      _refreshToken = result.refreshToken;
      _user = result.user;
      await _persistSession();
      notifyListeners();
      return true;
    } on ApiException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout({String? message, bool notifyServer = true}) async {
    final refresh = _refreshToken;
    _ticker?.cancel();
    _ticker = null;
    _user = null;
    _accessToken = null;
    _refreshToken = null;
    _warningVisible = false;
    _warningRemaining = Duration.zero;
    _message = message;
    await _clearLocal();
    notifyListeners();
    if (notifyServer && refresh != null) {
      try {
        await _api.logout(refresh);
      } catch (_) {}
    }
  }

  Future<void> _expire(String message) =>
      logout(message: message, notifyServer: false);

  void touch() {
    if (_user == null) return;
    final now = DateTime.now();
    _lastActivity = now;
    if (_warningVisible) {
      _warningVisible = false;
      _warningRemaining = Duration.zero;
      notifyListeners();
    }
    if (_lastPersist == null ||
        now.difference(_lastPersist!) > const Duration(seconds: 10)) {
      _lastPersist = now;
      _persistTimestamps();
    }
  }

  void clearMessage() {
    if (_message == null) return;
    _message = null;
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _tick() async {
    if (_user == null) return;
    final now = DateTime.now();
    if (_loginAt != null && rules.maxExpired(now.difference(_loginAt!))) {
      await _expire('Сессия истекла. Войдите снова.');
      return;
    }
    if (_lastActivity == null) return;
    final elapsed = now.difference(_lastActivity!);
    if (rules.idleExpired(elapsed)) {
      await _expire('Сессия завершена из-за неактивности.');
      return;
    }
    final warning = rules.shouldWarn(elapsed);
    final remaining = rules.warningRemaining(elapsed);
    if (warning != _warningVisible ||
        remaining.inSeconds != _warningRemaining.inSeconds) {
      _warningVisible = warning;
      _warningRemaining = remaining;
      notifyListeners();
    }
  }

  Future<void> _persistSession() async {
    await _prefs.setString(_kAccess, _accessToken ?? '');
    await _prefs.setString(_kRefresh, _refreshToken ?? '');
    await _prefs.setString(_kUser, jsonEncode(_user?.toJson() ?? {}));
    await _persistTimestamps();
  }

  Future<void> _persistTimestamps() async {
    if (_lastActivity != null) {
      await _prefs.setString(_kActivity, _lastActivity!.toIso8601String());
    }
    if (_loginAt != null) {
      await _prefs.setString(_kLoginAt, _loginAt!.toIso8601String());
    }
  }

  Future<void> _clearLocal() async {
    await _prefs.remove(_kAccess);
    await _prefs.remove(_kRefresh);
    await _prefs.remove(_kUser);
    await _prefs.remove(_kActivity);
    await _prefs.remove(_kLoginAt);
    _lastActivity = null;
    _loginAt = null;
    _lastPersist = null;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
