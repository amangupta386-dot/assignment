import '../core/network/api_client.dart';
import '../models/daily_plan_model.dart';

class PlanRepository {
  PlanRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DailyPlanModel> getTodayPlan() async {
    final response = await _apiClient.get('/plans/today');
    return DailyPlanModel.fromJson(Map<String, dynamic>.from(response.data['plan'] as Map));
  }

  Future<void> generateWeek({String? weekStart}) async {
    await _apiClient.post('/plans/generate-week', data: {
      if (weekStart != null) 'weekStart': weekStart,
    });
  }

  Future<DailyPlanModel> markTaskDone(String key) async {
    final response = await _apiClient.post('/plans/today/mark-done', data: {'key': key});
    return DailyPlanModel.fromJson(Map<String, dynamic>.from(response.data['plan'] as Map));
  }
}
