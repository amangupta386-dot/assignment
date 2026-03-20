import '../core/network/api_client.dart';
import '../core/data/local_fallback_store.dart';
import '../models/pattern_analytics_model.dart';
import '../models/weekly_analytics_model.dart';

class AnalyticsRepository {
  AnalyticsRepository(this._apiClient);

  final ApiClient _apiClient;
  final LocalFallbackStore _local = LocalFallbackStore.instance;

  Future<WeeklyAnalytics> getWeeklyAnalytics() async {
    try {
      final response = await _apiClient.get('/analytics/weekly');
      return WeeklyAnalytics.fromJson(Map<String, dynamic>.from(response.data as Map));
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) return _local.getWeeklyAnalytics();
      rethrow;
    }
  }

  Future<List<PatternAnalytics>> getPatternAnalytics() async {
    try {
      final response = await _apiClient.get('/analytics/patterns');
      final data = response.data['patterns'] as List<dynamic>;
      return data.map((e) => PatternAnalytics.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) return _local.getPatternAnalytics();
      rethrow;
    }
  }
}
