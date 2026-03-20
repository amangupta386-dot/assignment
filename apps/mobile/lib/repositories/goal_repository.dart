import '../core/network/api_client.dart';
import '../core/data/local_fallback_store.dart';
import '../models/weekly_goal_model.dart';

class GoalRepository {
  GoalRepository(this._apiClient);

  final ApiClient _apiClient;
  final LocalFallbackStore _local = LocalFallbackStore.instance;

  Future<void> upsertWeeklyGoal({
    required List<GoalProblemItem> goalProblems,
  }) async {
    final payload = goalProblems.map((e) => e.toJson()).toList();
    try {
      await _apiClient.post('/goals/weekly', data: {
        'goalProblems': payload,
      });
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) {
        _local.upsertWeeklyGoal(
          goalProblems: goalProblems,
        );
        return;
      }
      rethrow;
    }
  }

  Future<WeeklyGoalModel?> getCurrentWeeklyGoal() async {
    try {
      final response = await _apiClient.get('/goals/weekly/current');
      final goal = response.data['goal'];
      if (goal == null) return null;
      return WeeklyGoalModel.fromJson(Map<String, dynamic>.from(goal as Map));
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) return _local.getCurrentWeeklyGoal();
      rethrow;
    }
  }
}
