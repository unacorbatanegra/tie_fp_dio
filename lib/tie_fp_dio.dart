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
  return Success(serializer(body));
}

extension ToResult<T> on Response {
  Result<T> toResult() => fromDioResponse<T>(this);
}

extension ToResultFuture<T> on Future<Response> {
  Future<Result<T>> toResult([FromJson<T>? serializer]) async =>
      fromDioResponse<T>(await this, serializer: serializer);
}
