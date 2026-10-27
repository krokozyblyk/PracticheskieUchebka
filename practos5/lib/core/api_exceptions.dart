import 'package:dio/dio.dart';

sealed class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'Сервер недоступен. Проверьте соединение.',
  ]);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Требуется вход в систему.']);
}

class ForbiddenException extends ApiException {
  const ForbiddenException([
    super.message = 'Недостаточно прав для этого действия.',
  ]);
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Запись не найдена.']);
}

class ConflictException extends ApiException {
  const ConflictException(super.message);
}

class ValidationException extends ApiException {
  final Map<String, String> errors;

  const ValidationException(super.message, this.errors);
}

class ServerException extends ApiException {
  const ServerException([
    super.message = 'Ошибка на сервере. Попробуйте позже.',
  ]);
}

class RequestCancelledException extends ApiException {
  const RequestCancelledException([super.message = 'Запрос отменён.']);
}

ApiException mapHttpError(int status, dynamic body) {
  final map = body is Map ? body : const {};
  final rawMessage = map['message'];
  final message = rawMessage is String ? rawMessage : null;

  switch (status) {
    case 401:
      return UnauthorizedException(message ?? 'Требуется вход в систему.');
    case 403:
      return ForbiddenException(message ?? 'Недостаточно прав для этого действия.');
    case 404:
      return NotFoundException(message ?? 'Запись не найдена.');
    case 409:
      return ConflictException(message ?? 'Операция невозможна.');
    case 422:
      final rawErrors = map['errors'];
      final errors = <String, String>{};
      if (rawErrors is Map) {
        rawErrors.forEach((key, value) {
          errors['$key'] = '$value';
        });
      }
      return ValidationException(message ?? 'Ошибка валидации', errors);
    default:
      return ServerException(message ?? 'Неизвестная ошибка (код $status).');
  }
}

ApiException mapDioError(DioException error) {
  final existing = error.error;
  if (existing is ApiException) return existing;

  switch (error.type) {
    case DioExceptionType.cancel:
      return const RequestCancelledException();
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkException('Сервер не ответил вовремя.');
    case DioExceptionType.connectionError:
      return const NetworkException(
        'Не удалось соединиться с сервером. '
        'Если сервер запущен, проверьте ошибку CORS в консоли браузера.',
      );
    case DioExceptionType.badResponse:
      final status = error.response?.statusCode;
      if (status != null) {
        return mapHttpError(status, error.response?.data);
      }
      return const ServerException();
    default:
      return const ServerException();
  }
}

Future<T> guard<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on DioException catch (error) {
    throw mapDioError(error);
  }
}

Future<T> retryRead<T>(Future<T> Function() action) async {
  var attempt = 0;
  while (true) {
    try {
      return await action();
    } on RequestCancelledException {
      rethrow;
    } on NetworkException {
      attempt += 1;
      if (attempt >= 3) rethrow;
      await Future<void>.delayed(
        Duration(milliseconds: 300 * (1 << (attempt - 1))),
      );
    }
  }
}
