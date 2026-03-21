class WeeklyGoalModel {
  const WeeklyGoalModel({
    required this.fromDate,
    required this.toDate,
    required this.goalProblems,
  });

  final String fromDate;
  final String toDate;
  final List<GoalProblemItem> goalProblems;

  factory WeeklyGoalModel.fromJson(Map<String, dynamic> json) {
    final rawProblems = (json['goalProblems'] as List<dynamic>?) ??
        (json['focusPatterns'] as List<dynamic>?) ??
        const [];
    return WeeklyGoalModel(
      fromDate: (json['fromDate'] ?? json['weekStart'] ?? '').toString(),
      toDate: (json['toDate'] ?? json['weekEnd'] ?? '').toString(),
      goalProblems: rawProblems
          .whereType<Map>()
          .map((e) => GoalProblemItem.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.problemName.isNotEmpty && e.patternName.isNotEmpty)
          .toList(),
    );
  }
}

class WeeklyGoalPlanningInsights {
  const WeeklyGoalPlanningInsights({
    required this.fromDate,
    required this.toDate,
    required this.recommendedTarget,
    required this.suggestedNewProblems,
    required this.carryForwardProblems,
    required this.lastWeek,
    required this.recentPerformance,
  });

  final String fromDate;
  final String toDate;
  final int recommendedTarget;
  final int suggestedNewProblems;
  final List<GoalProblemItem> carryForwardProblems;
  final WeeklyGoalPerformanceSummary lastWeek;
  final List<WeeklyGoalPerformanceSummary> recentPerformance;

  factory WeeklyGoalPlanningInsights.fromJson(Map<String, dynamic> json) {
    return WeeklyGoalPlanningInsights(
      fromDate: (json['fromDate'] ?? '').toString(),
      toDate: (json['toDate'] ?? '').toString(),
      recommendedTarget: json['recommendedTarget'] as int? ?? 0,
      suggestedNewProblems: json['suggestedNewProblems'] as int? ?? 0,
      carryForwardProblems:
          (json['carryForwardProblems'] as List<dynamic>? ?? const [])
              .whereType<Map>()
              .map((item) =>
                  GoalProblemItem.fromJson(Map<String, dynamic>.from(item)))
              .toList(),
      lastWeek: WeeklyGoalPerformanceSummary.fromJson(
        Map<String, dynamic>.from(json['lastWeek'] as Map? ?? const {}),
      ),
      recentPerformance:
          (json['recentPerformance'] as List<dynamic>? ?? const [])
              .whereType<Map>()
              .map((item) => WeeklyGoalPerformanceSummary.fromJson(
                  Map<String, dynamic>.from(item)))
              .toList(),
    );
  }
}

class WeeklyGoalPerformanceSummary {
  const WeeklyGoalPerformanceSummary({
    required this.label,
    required this.fromDate,
    required this.toDate,
    required this.plannedCount,
    required this.completedDayOneCount,
    required this.completionRate,
    required this.unfinishedProblems,
  });

  final String label;
  final String fromDate;
  final String toDate;
  final int plannedCount;
  final int completedDayOneCount;
  final int completionRate;
  final List<GoalProblemItem> unfinishedProblems;

  factory WeeklyGoalPerformanceSummary.fromJson(Map<String, dynamic> json) {
    return WeeklyGoalPerformanceSummary(
      label: (json['label'] ?? '').toString(),
      fromDate: (json['fromDate'] ?? '').toString(),
      toDate: (json['toDate'] ?? '').toString(),
      plannedCount: json['plannedCount'] as int? ?? 0,
      completedDayOneCount: json['completedDayOneCount'] as int? ?? 0,
      completionRate: json['completionRate'] as int? ?? 0,
      unfinishedProblems:
          (json['unfinishedProblems'] as List<dynamic>? ?? const [])
              .whereType<Map>()
              .map((item) =>
                  GoalProblemItem.fromJson(Map<String, dynamic>.from(item)))
              .toList(),
    );
  }
}

class GoalProblemItem {
  const GoalProblemItem({
    required this.problemName,
    required this.patternName,
    required this.timeComplexity,
  });

  final String problemName;
  final String patternName;
  final String timeComplexity;

  factory GoalProblemItem.fromJson(Map<String, dynamic> json) {
    return GoalProblemItem(
      problemName: (json['problemName'] ?? '').toString(),
      patternName: (json['patternName'] ?? '').toString(),
      timeComplexity: (json['timeComplexity'] ?? 'Not set').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problemName': problemName,
      'patternName': patternName,
      'timeComplexity': timeComplexity,
    };
  }
}
