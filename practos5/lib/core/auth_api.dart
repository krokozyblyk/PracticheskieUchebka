import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/app_user.dart';
import '../models/customer.dart';
import '../models/role.dart';

class ProfileResult {
  final AppUser user;
  final Customer? customer;

  const ProfileResult({required this.user, this.customer});
}

class StatCount {
  final int active;
  final int deleted;

  const StatCount({required this.active, required this.deleted});

  factory StatCount.fromJson(Map<String, dynamic> json) => StatCount(
        active: (json['active'] as num?)?.toInt() ?? 0,
        deleted: (json['deleted'] as num?)?.toInt() ?? 0,
      );
}

class StatsResult {
  final Map<String, StatCount> counts;

  const StatsResult(this.counts);

  factory StatsResult.fromJson(Map<String, dynamic> json) {
    final raw = json['counts'];
    final counts = <String, StatCount>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is Map) {
          counts['$key'] = StatCount.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }
    return StatsResult(counts);
  }
}

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<AuthResult> login(String username, String password) {
    return guard(() async {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username.trim(), 'password': password},
      );
      return AuthResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    });
  }

  Future<AppUser> register({
    required String username,
    required String password,
    required String fullName,
    required String email,
  }) {
    return guard(() async {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'username': username.trim(),
          'password': password,
          'fullName': fullName.trim(),
          'email': email.trim(),
        },
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      return AppUser.fromJson(
        Map<String, dynamic>.from(data['user'] as Map),
      );
    });
  }

  Future<AuthResult> refresh(String refreshToken) {
    return guard(() async {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      return AuthResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    });
  }

  Future<void> logout(String refreshToken) {
    return guard(() async {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    });
  }

  Future<AppUser> me() {
    return guard(() async {
      final response = await _dio.get('/auth/me');
      return AppUser.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    });
  }

  Future<ProfileResult> profile() {
    return guard(() async {
      final response = await _dio.get('/profile');
      final data = Map<String, dynamic>.from(response.data as Map);
      final user = AppUser.fromJson(
        Map<String, dynamic>.from(data['user'] as Map),
      );
      final rawCustomer = data['customer'];
      final customer = rawCustomer is Map
          ? Customer.fromJson(Map<String, dynamic>.from(rawCustomer))
          : null;
      return ProfileResult(user: user, customer: customer);
    });
  }

  Future<List<AppUser>> users() {
    return guard(() async {
      final response = await _dio.get('/users');
      final raw = response.data;
      if (raw is! List) return const <AppUser>[];
      return raw
          .whereType<Map>()
          .map((item) => AppUser.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    });
  }

  Future<AppUser> updateRole(int id, Role role) {
    return guard(() async {
      final response = await _dio.put(
        '/users/$id/role',
        data: {'role': role.code},
      );
      return AppUser.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    });
  }

  Future<StatsResult> stats() {
    return guard(() async {
      final response = await _dio.get('/stats');
      return StatsResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    });
  }
}
