import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_exceptions.dart';
import 'config.dart';

Map<String, dynamic> debugQueryParameters() {
  const keys = ['__delay', '__fail'];
  final query = Uri.base.queryParameters;
  final result = <String, dynamic>{};
  for (final key in keys) {
    final value = query[key];
    if (value != null && value.isNotEmpty) result[key] = value;
  }
  return result;
}

Dio buildDio({
  Dio? client,
  String? Function()? tokenProvider,
  Future<bool> Function()? onUnauthorized,
  void Function()? onAuthFailed,
}) {
  final dio =
      client ??
      Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: apiConnectTimeout,
          receiveTimeout: apiReceiveTimeout,
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        debugQueryParameters().forEach((key, value) {
          options.queryParameters.putIfAbsent(key, () => value);
        });
        final token = tokenProvider?.call();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          debugPrint('[API] ${options.method} ${options.uri}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint(
            '[API] ${response.statusCode} ${response.requestOptions.uri}',
          );
        }
        final status = response.statusCode ?? 0;
        if (status >= 400) {
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: mapHttpError(status, response.data),
            ),
            true,
          );
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          debugPrint('[API] сбой ${error.requestOptions.uri}: ${error.type}');
        }
        final status = error.response?.statusCode;
        final path = error.requestOptions.path;
        final retried = error.requestOptions.extra['retried'] == true;

        if (status == 401 &&
            !path.contains('/auth/') &&
            onUnauthorized != null) {
          if (!retried) {
            final refreshed = await onUnauthorized();
            if (refreshed) {
              final options = error.requestOptions;
              options.extra['retried'] = true;
              final token = tokenProvider?.call();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              try {
                final response = await dio.fetch(options);
                return handler.resolve(response);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            }
          }
          onAuthFailed?.call();
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
}
