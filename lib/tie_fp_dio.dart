library tie_fp_dio;

import 'package:dio/dio.dart';
import 'package:tie_fp/tie_fp.dart';

part 'src/api_serializer.dart';

Result<T> fromDioResponse<T>(
  Response response, {
  FromJson<T>? serializer,
  bool Function(Response resp)? isError,
  E Function<E>(Response parseError)? parseError,
}) {
  if (isError?.call(response) ?? false) {
    return Failure(parseError?.call(response));
  }
  if ((response.statusCode ?? 500) >= 400) {
    return Failure(response.statusMessage);
  }
  final body = response.data;
  serializer ??= ApiSerializer.get<T>();
  if (serializer == null) {
    throw 'serializer not found';
  }
  try {
    final v = serializer(body);
    return Success(v);
  } catch (e, s) {
    return Failure(e, s);
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
  }) async {
    try {
      return fromDioResponse<T>(
        await this,
        serializer: serializer,
        isError: isError,
        parseError: parseError,
      );
    } catch (e, s) {
      return Failure(e, s);
    }
  }
}
