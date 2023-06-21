library tie_fp_dio;

import 'package:dio/dio.dart';
import 'package:tie_fp/tie_fp.dart';

part 'src/api_serializer.dart';

extension ToResult on Response {
  Result<T> toResult<T>() => fromDioResponse(this);

  Result<T> fromDioResponse<T>(
    Response response, {
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
    final converter = ApiSerializer.get<T>();
    if (converter == null) {
      throw 'serializer not found';
    }
    return Success(converter(body));
  }
}
