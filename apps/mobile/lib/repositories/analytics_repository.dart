import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/data/local_fallback_store.dart';
import '../models/analytics_dashboard_model.dart';
import '../models/pattern_analytics_model.dart';
import '../models/weekly_analytics_model.dart';

class AnalyticsRepository {
  AnalyticsRepository(this._apiClient);

  final ApiClient _apiClient;
  final LocalFallbackStore _local = LocalFallbackStore.instance;

  Future<AnalyticsDashboard> getDashboardAnalytics() async {
    try {
      return await _getLegacyDashboardAnalytics();
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) {
        return _local.getAnalyticsDashboard();
      }
      if (_isLegacyEndpointMissing(e)) {
        final response = await _apiClient.get('/analytics/dashboard');
        return AnalyticsDashboard.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      rethrow;
    }
  }

  Future<AnalyticsDashboard> _getLegacyDashboardAnalytics() async {
    try {
      final weeklyResponse = await _apiClient.get('/analytics/weekly');
      final patternsResponse = await _apiClient.get('/analytics/patterns');
      final weekly = WeeklyAnalytics.fromJson(
        Map<String, dynamic>.from(weeklyResponse.data as Map),
      );
      final rawPatterns =
          (patternsResponse.data['patterns'] as List<dynamic>? ??
                  const <dynamic>[])
              .whereType<Map>()
              .map((item) =>
                  PatternAnalytics.fromJson(Map<String, dynamic>.from(item)))
              .toList();
      return _buildLegacyDashboard(weekly, rawPatterns);
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) {
        return _local.getAnalyticsDashboard();
      }
      rethrow;
    }
  }

  bool _isLegacyEndpointMissing(Object error) {
    if (error is! DioException) return false;
    return error.type == DioExceptionType.badResponse &&
        error.response?.statusCode == 404;
  }

  AnalyticsDashboard _buildLegacyDashboard(
    WeeklyAnalytics weekly,
    List<PatternAnalytics> patterns,
  ) {
    const stageDefinitions = <Map<String, String>>[
      {
        'key': 'REVISE',
        'title': 'Learn About Problem',
        'shortLabel': 'Stage 1',
        'description': 'Learn the problem and understand the approach.',
      },
      {
        'key': 'SOLVE_AGAIN',
        'title': 'Revise And Solve',
        'shortLabel': 'Stage 2',
        'description': 'Revisit the concept and solve the problem again.',
      },
      {
        'key': 'SOLVE_WITHOUT_SEEING',
        'title': 'Solve Without Seeing',
        'shortLabel': 'Stage 3',
        'description': 'Solve the problem independently without looking.',
      },
      {
        'key': 'FINAL_REVISIT',
        'title': 'Revisit With Timer',
        'shortLabel': 'Stage 4',
        'description': 'Revisit the problem under timed conditions.',
      },
    ];

    List<StageMetric> emptyStageMetrics() {
      return stageDefinitions
          .map(
            (stage) => StageMetric(
              stageKey: stage['key']!,
              title: stage['title']!,
              shortLabel: stage['shortLabel']!,
              description: stage['description']!,
              due: 0,
              completed: 0,
              overdue: 0,
              backlog: 0,
            ),
          )
          .toList();
    }

    return AnalyticsDashboard(
      generatedOn: DateTime.now().toIso8601String(),
      daily: AnalyticsPeriod(
        label: 'Today',
        totalDue: 0,
        totalCompleted: 0,
        overdue: 0,
        completionScore: 0,
        stageMetrics: emptyStageMetrics(),
      ),
      weekly: AnalyticsWeek(
        label: 'Weekly Summary',
        activeDays: ((weekly.consistencyScore / 100) * 7).round(),
        consistencyScore: weekly.consistencyScore,
        totalCompleted: weekly.actualRevisions,
        fullCycleCompleted: 0,
        stageMetrics: emptyStageMetrics(),
        goalProgress: GoalProgress(
          targetProblems: weekly.targetProblems,
          targetRevisions: weekly.targetRevisions,
          actualProblems: weekly.actualProblems,
          actualRevisions: weekly.actualRevisions,
          problemsProgress: weekly.problemsProgress,
          revisionsProgress: weekly.revisionsProgress,
        ),
      ),
      monthly: AnalyticsMonth(
        label: 'Monthly Summary',
        activeDays: 0,
        totalCompleted: weekly.actualRevisions,
        fullCycleCompleted: 0,
        totalProblemsStarted: weekly.actualProblems,
        stageMetrics: emptyStageMetrics(),
        weekBreakdown: const <MonthlyWeekBreakdown>[],
      ),
      patterns: patterns
          .map(
            (item) => PatternInsight(
              pattern: item.pattern,
              solved: item.solved,
              failed: item.failed,
              successRate: item.successRate,
            ),
          )
          .toList(),
    );
  }
}
