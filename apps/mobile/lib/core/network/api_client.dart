import 'package:dio/dio.dart';
import '../utils/app_config.dart';

class ApiClient {
  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
            sendTimeout: const Duration(seconds: 8),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  final Dio _dio;
  DateTime? _offlineUntil;

  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (_isInOfflineCooldown()) {
      throw _offlineDioException(path);
    }
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (error) {
      _updateOfflineCooldown(error);
      rethrow;
    }
  }

  Future<Response<dynamic>> post(String path, {Object? data}) async {
    if (_isInOfflineCooldown()) {
      throw _offlineDioException(path);
    }
    try {
      return await _dio.post(path, data: data);
    } catch (error) {
      _updateOfflineCooldown(error);
      rethrow;
    }
  }

  bool isConnectivityError(Object error) {
    if (error is! DioException) return false;
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }

  bool _isInOfflineCooldown() {
    final until = _offlineUntil;
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      _offlineUntil = null;
      return false;
    }
    return true;
  }

  void _updateOfflineCooldown(Object error) {
    if (!isConnectivityError(error)) return;
    _offlineUntil = DateTime.now().add(const Duration(seconds: 30));
  }

  DioException _offlineDioException(String path) {
    return DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.connectionError,
      message: 'Offline cooldown active',
    );
  }
}
