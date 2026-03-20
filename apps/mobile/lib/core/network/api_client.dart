import 'package:dio/dio.dart';
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
  DateTime? _offlineUntil;

  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (_isInOfflineCooldown()) {
      throw _offlineDioException(path);
    }
    return _executeWithFailover(
      () => _dio.get(path, queryParameters: queryParameters),
      path,
    );
  }

  Future<Response<dynamic>> post(String path, {Object? data}) async {
    if (_isInOfflineCooldown()) {
      throw _offlineDioException(path);
    }
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

  Future<Response<dynamic>> _executeWithFailover(
    Future<Response<dynamic>> Function() request,
    String path,
  ) async {
    Object? lastError;
    while (true) {
      try {
        return await request();
      } catch (error) {
        lastError = error;
        if (isConnectivityError(error) && _switchToNextBaseUrl()) {
          continue;
        }
        _updateOfflineCooldown(error);
        rethrow;
      }
    }
    // Keeps analyzer happy for static flow; loop always returns/throws.
    // ignore: dead_code
    throw lastError ?? _offlineDioException(path);
  }

  bool _switchToNextBaseUrl() {
    if (_activeBaseUrlIndex + 1 >= _baseUrls.length) return false;
    _activeBaseUrlIndex += 1;
    _dio.options.baseUrl = _baseUrls[_activeBaseUrlIndex];
    return true;
  }

  DioException _offlineDioException(String path) {
    return DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.connectionError,
      message: 'Offline cooldown active',
    );
  }
}
