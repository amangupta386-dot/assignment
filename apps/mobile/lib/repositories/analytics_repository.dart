import '../core/network/api_client.dart';
import '../models/pattern_analytics_model.dart';
import '../models/weekly_analytics_model.dart';

class AnalyticsRepository {
  AnalyticsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<WeeklyAnalytics> getWeeklyAnalytics() async {
    final response = await _apiClient.get('/analytics/weekly');
    return WeeklyAnalytics.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<List<PatternAnalytics>> getPatternAnalytics() async {
    final response = await _apiClient.get('/analytics/patterns');
    final data = response.data['patterns'] as List<dynamic>;
    return data.map((e) => PatternAnalytics.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }
}
