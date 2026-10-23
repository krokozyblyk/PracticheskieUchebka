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

Dio buildDio({Dio? client}) {
  final dio = client ??
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
      onError: (error, handler) {
        if (kDebugMode) {
          debugPrint('[API] сбой ${error.requestOptions.uri}: ${error.type}');
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
}
