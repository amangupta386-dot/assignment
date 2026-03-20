import '../core/network/api_client.dart';
import '../models/weekly_goal_model.dart';

class GoalRepository {
  GoalRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<void> upsertWeeklyGoal({
    required int targetProblems,
    required int targetRevisions,
    required List<String> focusPatterns,
  }) async {
    await _apiClient.post('/goals/weekly', data: {
      'targetProblems': targetProblems,
      'targetRevisions': targetRevisions,
      'focusPatterns': focusPatterns,
    });
  }

  Future<WeeklyGoalModel?> getCurrentWeeklyGoal() async {
    final response = await _apiClient.get('/goals/weekly/current');
    final goal = response.data['goal'];
    if (goal == null) return null;
    return WeeklyGoalModel.fromJson(Map<String, dynamic>.from(goal as Map));
  }
}
