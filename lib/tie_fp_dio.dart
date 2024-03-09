library tie_fp_dio;

import 'package:dio/dio.dart';
import 'package:tie_fp/tie_fp.dart';

part 'src/api_serializer.dart';

Result<T> fromDioResponse<T>(
  Response response, {
  FromJson<T>? serializer,
  bool Function(Response resp)? isError,
  E Function<E>(Response parseError)? parseError,
  void Function(Response resp)? getOriginalResponse,
}) {
  if (isError?.call(response) ?? false) {
    return Failure(parseError?.call(response));
  }
  // if ((response.statusCode ?? 500) >= 400) {
  //   return Failure(response.statusMessage);
  // }
  final body = response.data;
  if (body is! Map) {
    throw 'body is not Map, use toResultList() instead';
  }
  serializer ??= ApiSerializer.get<T>() ?? (json) => json as T;

  getOriginalResponse?.call(response);

  try {
    final v = serializer(Map<String, dynamic>.from(body));
    return Success(v);
  } catch (exception, stackTrace) {
    return Failure(exception, stackTrace);
  }
}

Result<List<T>> fromDioResponseList<T>(
  Response response, {
  FromJson<T>? serializer,
  bool Function(Response resp)? isError,
  E Function<E>(Response parseError)? parseError,
  void Function(Response resp)? getOriginalResponse,
}) {
  if (isError?.call(response) ?? false) {
    return Failure(parseError?.call(response));
  }
  // if ((response.statusCode ?? 500) >= 400) {
  //   return Failure(response.statusMessage);
  // }
  final body = response.data;
  if (body is! List) {
    throw 'body is not list, use toResult() instead';
  }
  serializer ??= ApiSerializer.get<T>() ?? (json) => json as T;
  getOriginalResponse?.call(response);
  try {
    final value = body.map(
      (e) {
        if (e is T) {
          return e;
        }
        if (serializer == null) {
          throw 'serializer not found';
        }
        return serializer(e);
      },
    ).toList();

    return Success(value);
  } catch (exception, stackTrace) {
    return Failure(exception, stackTrace);
  }
}

extension ToResult<T> on Response {
  Result<T> toResult() => fromDioResponse<T>(this);
}

extension ToResultFuture<J> on Future<Response<J>> {
  Future<Result<T>> toResult<T>({
    FromJson<T>? serializer,
    bool Function(Response resp)? isError,
    E Function<E>(Response parseError)? parseError,
    void Function(Response resp)? getOriginalResponse,
  }) async {
    try {
      return fromDioResponse(
        await this,
        serializer: serializer,
        isError: isError,
        parseError: parseError,
        getOriginalResponse: getOriginalResponse,
      );
    } catch (e, s) {
      return Failure(e, s);
    }
  }

  Future<Result<List<T>>> toResultList<T>({
    FromJson<T>? serializer,
    bool Function(Response resp)? isError,
    E Function<E>(Response parseError)? parseError,
    void Function(Response resp)? getOriginalResponse,
  }) async {
    try {
      return fromDioResponseList(
        await this,
        serializer: serializer,
        isError: isError,
        parseError: parseError,
        getOriginalResponse: getOriginalResponse,
      );
    } catch (e, s) {
      return Failure(e, s);
    }
  }
}
