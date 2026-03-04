import "package:dio/dio.dart";

class ApiClient {
  ApiClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment("API_BASE_URL", defaultValue: "http://10.0.2.2"),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {"Content-Type": "application/json"}
    )
  );
}
