// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';
import 'package:tie_fp/tie_fp.dart';
import 'package:tie_fp_dio/tie_fp_dio.dart';

void main() async {
  const baseUrl = 'https://example.com/';
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  final dioAdapter = DioAdapter(dio: dio);

  dioAdapter.onGet(
    '/test',
    (server) => server.reply(
      200,
      {'message': 'Success!', 'result': false},
      // Reply would wait for one-sec before returning data.
      delay: const Duration(seconds: 1),
    ),
  );
  dioAdapter.onGet(
    '/list',
    (server) => server.reply(
      200,
      List.generate(10, (index) => {'message': 'Success!', 'result': false}),
      // Reply would wait for one-sec before returning data.
      delay: const Duration(seconds: 1),
    ),
  );
  dioAdapter.onGet(
    '/exception',
    (server) => server.reply(
      400,
      {'message': 'Error', 'result': false},
      // Reply would wait for one-sec before returning data.
      delay: const Duration(seconds: 1),
    ),
  );
  setUp(() {
    dio.httpClientAdapter = dioAdapter;
    dio.options.baseUrl = baseUrl;
    // ApiSerializer.register<Model>(Model.fromMap);
  });
  group('Test serialization', () {
    test('Test inline-serialization', () async {
      final result = await dio.get('/test').toResult<Model>(
            serializer: Model.fromMap,
          );
      expect(result, isA<Result<Model>>());
      expect(result.isError(), false);
      expect(result.getValue(), isA<Model>());
      expect(result.getValue().message, 'Success!');
    });
    test('Test outside serialization', () async {
      ApiSerializer.register(Model.fromMap);
      final result = await dio.get('/test').toResult<Model>();
      expect(result, isA<Result<Model>>());
      expect(result.isError(), false);
      expect(result.getValue(), isA<Model>());
      expect(result.getValue().message, 'Success!');
    });
    test('Test exception', () async {
      final result = await dio.get('/exception').toResult<Model>(
            serializer: Model.fromMap,
            isError: (resp) => resp.statusCode! >= 400,
          );
      expect(result, isA<Result<Model>>());
      expect(result.isError(), true);
    });
    test('Test list serialization', () async {
      final result = await dio.get('/list').toResultList<Model>(
            serializer: Model.fromMap,
          );
      expect(result, isA<Result<List<Model>>>());
      expect(result.isError(), false);
    });
  });
}

class Model {
  final String message;
  Model({
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
    };
  }

  factory Model.fromMap(Map<String, dynamic> map) {
    return Model(
      message: map['message'] as String,
    );
  }
}
