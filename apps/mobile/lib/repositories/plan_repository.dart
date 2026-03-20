import '../core/network/api_client.dart';
import '../core/data/local_fallback_store.dart';
import '../models/daily_plan_model.dart';

class PlanRepository {
  PlanRepository(this._apiClient);

  final ApiClient _apiClient;
  final LocalFallbackStore _local = LocalFallbackStore.instance;

  Future<DailyPlanModel> getTodayPlan() async {
    try {
      final response = await _apiClient.get('/plans/today');
      return DailyPlanModel.fromJson(Map<String, dynamic>.from(response.data['plan'] as Map));
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) return _local.getTodayPlan();
      rethrow;
    }
  }

  Future<void> generateWeek({String? weekStart}) async {
    try {
      await _apiClient.post('/plans/generate-week', data: {
        if (weekStart != null) 'weekStart': weekStart,
      });
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) {
        _local.getTodayPlan();
        return;
      }
      rethrow;
    }
  }

  Future<DailyPlanModel> markTaskDone(String key) async {
    try {
      final response = await _apiClient.post('/plans/today/mark-done', data: {'key': key});
      return DailyPlanModel.fromJson(Map<String, dynamic>.from(response.data['plan'] as Map));
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) return _local.markTaskDone(key);
      rethrow;
    }
  }
}
