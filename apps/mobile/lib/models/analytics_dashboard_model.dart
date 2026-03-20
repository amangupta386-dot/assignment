class AnalyticsDashboard {
  const AnalyticsDashboard({
    required this.generatedOn,
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.patterns,
  });

  final String generatedOn;
  final AnalyticsPeriod daily;
  final AnalyticsWeek weekly;
  final AnalyticsMonth monthly;
  final List<PatternInsight> patterns;

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> json) {
    return AnalyticsDashboard(
      generatedOn: (json['generatedOn'] ?? '').toString(),
      daily: AnalyticsPeriod.fromJson(
          Map<String, dynamic>.from(json['daily'] as Map? ?? const {})),
      weekly: AnalyticsWeek.fromJson(
          Map<String, dynamic>.from(json['weekly'] as Map? ?? const {})),
      monthly: AnalyticsMonth.fromJson(
          Map<String, dynamic>.from(json['monthly'] as Map? ?? const {})),
      patterns: (json['patterns'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) =>
              PatternInsight.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class AnalyticsPeriod {
  const AnalyticsPeriod({
    required this.label,
    required this.totalDue,
    required this.totalCompleted,
    required this.overdue,
    required this.completionScore,
    required this.stageMetrics,
  });

  final String label;
  final int totalDue;
  final int totalCompleted;
  final int overdue;
  final int completionScore;
  final List<StageMetric> stageMetrics;

  factory AnalyticsPeriod.fromJson(Map<String, dynamic> json) {
    return AnalyticsPeriod(
      label: (json['label'] ?? '').toString(),
      totalDue: json['totalDue'] as int? ?? 0,
      totalCompleted: json['totalCompleted'] as int? ?? 0,
      overdue: json['overdue'] as int? ?? 0,
      completionScore: json['completionScore'] as int? ?? 0,
      stageMetrics: (json['stageMetrics'] as List<dynamic>? ??
              const <dynamic>[])
          .whereType<Map>()
          .map((item) => StageMetric.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class AnalyticsWeek {
  const AnalyticsWeek({
    required this.label,
    required this.activeDays,
    required this.consistencyScore,
    required this.totalCompleted,
    required this.fullCycleCompleted,
    required this.stageMetrics,
    required this.goalProgress,
  });

  final String label;
  final int activeDays;
  final int consistencyScore;
  final int totalCompleted;
  final int fullCycleCompleted;
  final List<StageMetric> stageMetrics;
  final GoalProgress goalProgress;

  factory AnalyticsWeek.fromJson(Map<String, dynamic> json) {
    return AnalyticsWeek(
      label: (json['label'] ?? '').toString(),
      activeDays: json['activeDays'] as int? ?? 0,
      consistencyScore: json['consistencyScore'] as int? ?? 0,
      totalCompleted: json['totalCompleted'] as int? ?? 0,
      fullCycleCompleted: json['fullCycleCompleted'] as int? ?? 0,
      stageMetrics: (json['stageMetrics'] as List<dynamic>? ??
              const <dynamic>[])
          .whereType<Map>()
          .map((item) => StageMetric.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      goalProgress: GoalProgress.fromJson(
          Map<String, dynamic>.from(json['goalProgress'] as Map? ?? const {})),
    );
  }
}

class AnalyticsMonth {
  const AnalyticsMonth({
    required this.label,
    required this.activeDays,
    required this.totalCompleted,
    required this.fullCycleCompleted,
    required this.totalProblemsStarted,
    required this.stageMetrics,
    required this.weekBreakdown,
  });

  final String label;
  final int activeDays;
  final int totalCompleted;
  final int fullCycleCompleted;
  final int totalProblemsStarted;
  final List<StageMetric> stageMetrics;
  final List<MonthlyWeekBreakdown> weekBreakdown;

  factory AnalyticsMonth.fromJson(Map<String, dynamic> json) {
    return AnalyticsMonth(
      label: (json['label'] ?? '').toString(),
      activeDays: json['activeDays'] as int? ?? 0,
      totalCompleted: json['totalCompleted'] as int? ?? 0,
      fullCycleCompleted: json['fullCycleCompleted'] as int? ?? 0,
      totalProblemsStarted: json['totalProblemsStarted'] as int? ?? 0,
      stageMetrics: (json['stageMetrics'] as List<dynamic>? ??
              const <dynamic>[])
          .whereType<Map>()
          .map((item) => StageMetric.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      weekBreakdown: (json['weekBreakdown'] as List<dynamic>? ??
              const <dynamic>[])
          .whereType<Map>()
          .map((item) =>
              MonthlyWeekBreakdown.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class StageMetric {
  const StageMetric({
    required this.stageKey,
    required this.title,
    required this.shortLabel,
    required this.description,
    required this.due,
    required this.completed,
    required this.overdue,
    required this.backlog,
  });

  final String stageKey;
  final String title;
  final String shortLabel;
  final String description;
  final int due;
  final int completed;
  final int overdue;
  final int backlog;

  factory StageMetric.fromJson(Map<String, dynamic> json) {
    return StageMetric(
      stageKey: (json['stageKey'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      shortLabel: (json['shortLabel'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      due: json['due'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      overdue: json['overdue'] as int? ?? 0,
      backlog: json['backlog'] as int? ?? 0,
    );
  }
}

class GoalProgress {
  const GoalProgress({
    required this.targetProblems,
    required this.targetRevisions,
    required this.actualProblems,
    required this.actualRevisions,
    required this.problemsProgress,
    required this.revisionsProgress,
  });

  final int targetProblems;
  final int targetRevisions;
  final int actualProblems;
  final int actualRevisions;
  final int problemsProgress;
  final int revisionsProgress;

  factory GoalProgress.fromJson(Map<String, dynamic> json) {
    return GoalProgress(
      targetProblems: json['targetProblems'] as int? ?? 0,
      targetRevisions: json['targetRevisions'] as int? ?? 0,
      actualProblems: json['actualProblems'] as int? ?? 0,
      actualRevisions: json['actualRevisions'] as int? ?? 0,
      problemsProgress: json['problemsProgress'] as int? ?? 0,
      revisionsProgress: json['revisionsProgress'] as int? ?? 0,
    );
  }
}

class MonthlyWeekBreakdown {
  const MonthlyWeekBreakdown({
    required this.label,
    required this.startDate,
    required this.endDate,
    required this.totalCompleted,
    required this.stageMetrics,
  });

  final String label;
  final String startDate;
  final String endDate;
  final int totalCompleted;
  final List<StageMetric> stageMetrics;

  factory MonthlyWeekBreakdown.fromJson(Map<String, dynamic> json) {
    return MonthlyWeekBreakdown(
      label: (json['label'] ?? '').toString(),
      startDate: (json['startDate'] ?? '').toString(),
      endDate: (json['endDate'] ?? '').toString(),
      totalCompleted: json['totalCompleted'] as int? ?? 0,
      stageMetrics: (json['stageMetrics'] as List<dynamic>? ??
              const <dynamic>[])
          .whereType<Map>()
          .map((item) => StageMetric.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class PatternInsight {
  const PatternInsight({
    required this.pattern,
    required this.solved,
    required this.failed,
    required this.successRate,
  });

  final String pattern;
  final int solved;
  final int failed;
  final int successRate;

  factory PatternInsight.fromJson(Map<String, dynamic> json) {
    return PatternInsight(
      pattern: (json['pattern'] ?? '').toString(),
      solved: json['solved'] as int? ?? 0,
      failed: json['failed'] as int? ?? 0,
      successRate: json['successRate'] as int? ?? 0,
    );
  }
}
