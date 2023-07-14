part of tie_fp_dio;

typedef FromJson<K> = K Function(Map<String, dynamic> json);

abstract class ApiSerializer {
  static final serializerMap = <Object, FromJson>{};

  static void register<J>(FromJson<J> fromJson) {
    if (serializerMap.containsKey(J)) return;
    serializerMap[J] = fromJson;
  }

  static FromJson<J>? get<J>() => serializerMap[J] as FromJson<J>?;
}
