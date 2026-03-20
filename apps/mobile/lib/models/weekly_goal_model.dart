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

class GoalProblemItem {
  const GoalProblemItem({
    required this.problemName,
    required this.patternName,
  });

  final String problemName;
  final String patternName;

  factory GoalProblemItem.fromJson(Map<String, dynamic> json) {
    return GoalProblemItem(
      problemName: (json['problemName'] ?? '').toString(),
      patternName: (json['patternName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problemName': problemName,
      'patternName': patternName,
    };
  }
}
