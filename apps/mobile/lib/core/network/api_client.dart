import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_config.dart';

class ApiClient {
  ApiClient()
      : _baseUrls = AppConfig.baseUrls,
        _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrls.first,
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
            sendTimeout: const Duration(seconds: 8),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  final Dio _dio;
  final List<String> _baseUrls;
  int _activeBaseUrlIndex = 0;

  Future<Response<dynamic>> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return _executeWithFailover(
      () => _dio.get(path, queryParameters: queryParameters),
      path,
    );
  }

  Future<Response<dynamic>> post(String path, {Object? data}) async {
    return _executeWithFailover(
      () => _dio.post(path, data: data),
      path,
    );
  }

  bool isConnectivityError(Object error) {
    if (error is! DioException) return false;
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }

  Future<Response<dynamic>> _executeWithFailover(
    Future<Response<dynamic>> Function() request,
    String path,
  ) async {
    while (true) {
      try {
        debugPrint('API ${_dio.options.method} ${_dio.options.baseUrl}$path');
        return await request();
      } catch (error) {
        if (isConnectivityError(error)) {
          debugPrint(
              'API connectivity failure at ${_dio.options.baseUrl}$path: $error');
        }
        if (isConnectivityError(error) && _switchToNextBaseUrl()) {
          continue;
        }
        rethrow;
      }
    }
    // Keeps analyzer happy for static flow; loop always returns/throws.
    // ignore: dead_code
    throw DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.unknown,
      message: 'Unknown API failure',
    );
  }

  bool _switchToNextBaseUrl() {
    if (_activeBaseUrlIndex + 1 >= _baseUrls.length) return false;
    _activeBaseUrlIndex += 1;
    _dio.options.baseUrl = _baseUrls[_activeBaseUrlIndex];
    debugPrint('Switching API base URL to ${_dio.options.baseUrl}');
    return true;
  }
}
