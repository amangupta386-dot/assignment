import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/data/local_fallback_store.dart';
import '../core/utils/app_config.dart';
import '../models/weekly_goal_model.dart';

class GoalRepository {
  GoalRepository(this._apiClient);

  final ApiClient _apiClient;
  final LocalFallbackStore _local = LocalFallbackStore.instance;

  Future<void> upsertWeeklyGoal({
    required DateTime fromDate,
    required DateTime toDate,
    required List<GoalProblemItem> goalProblems,
  }) async {
    final payload = goalProblems.map((e) => e.toJson()).toList();
    final fromDateString = _toDateOnly(fromDate);
    final toDateString = _toDateOnly(toDate);
    try {
      await _apiClient.post('/goals/weekly', data: {
        'fromDate': fromDateString,
        'toDate': toDateString,
        'goalProblems': payload,
      });
      await _syncGoalProblemsToProblems(goalProblems);
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) {
        final detail = e is DioException
            ? (e.message ?? e.error?.toString() ?? e.toString())
            : e.toString();
        throw Exception(
          'Unable to save weekly goal to database. API server is unreachable. '
          'Please make sure the phone and backend are on the same network. '
          'Tried APIs: ${AppConfig.baseUrls.join(', ')}. '
          'Last error: $detail',
        );
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
      if (_apiClient.isConnectivityError(e)) {
        return _local.getCurrentWeeklyGoal();
      }
      rethrow;
    }
  }

  Future<List<WeeklyGoalModel>> getMonthlyTimeline(DateTime month) async {
    final monthString =
        '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';
    try {
      final response = await _apiClient.get('/goals/weekly/timeline',
          queryParameters: {'month': monthString});
      final data =
          (response.data['timelines'] as List<dynamic>? ?? const <dynamic>[]);
      return data
          .whereType<Map>()
          .map((e) => WeeklyGoalModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) {
        return _local.getMonthlyTimeline(month);
      }
      rethrow;
    }
  }

  Future<void> _syncGoalProblemsToProblems(
      List<GoalProblemItem> goalProblems) async {
    if (goalProblems.isEmpty) return;

    try {
      final response = await _apiClient.get('/problems');
      final raw =
          (response.data['problems'] as List<dynamic>? ?? const <dynamic>[]);
      final existingKeys = raw.whereType<Map>().map((e) {
        final title = (e['title'] ?? '').toString().trim().toLowerCase();
        final pattern = (e['pattern'] ?? '').toString().trim().toLowerCase();
        return '$title|$pattern';
      }).toSet();

      for (final item in goalProblems) {
        final key =
            '${item.problemName.trim().toLowerCase()}|${item.patternName.trim().toLowerCase()}';
        if (existingKeys.contains(key)) continue;

        await _apiClient.post('/problems', data: {
          'title': item.problemName,
          'platform': 'OTHER',
          'difficulty': 'MEDIUM',
          'pattern': item.patternName,
          'initialStatus': 'NOT_SOLVED',
        });
        existingKeys.add(key);
      }
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) {
        _local.syncProblemsFromGoal(goalProblems);
        return;
      }
      rethrow;
    }
  }

  String _toDateOnly(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
