class WeeklyGoalModel {
  const WeeklyGoalModel({
    required this.targetProblems,
    required this.targetRevisions,
    required this.focusPatterns,
  });

  final int targetProblems;
  final int targetRevisions;
  final List<String> focusPatterns;

  factory WeeklyGoalModel.fromJson(Map<String, dynamic> json) {
    return WeeklyGoalModel(
      targetProblems: json['targetProblems'] as int,
      targetRevisions: json['targetRevisions'] as int,
      focusPatterns: (json['focusPatterns'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
    );
  }
}
