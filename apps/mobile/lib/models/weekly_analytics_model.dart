class WeeklyAnalytics {
  const WeeklyAnalytics({
    required this.targetProblems,
    required this.targetRevisions,
    required this.actualProblems,
    required this.actualRevisions,
    required this.problemsProgress,
    required this.revisionsProgress,
    required this.consistencyScore,
  });

  final int targetProblems;
  final int targetRevisions;
  final int actualProblems;
  final int actualRevisions;
  final int problemsProgress;
  final int revisionsProgress;
  final int consistencyScore;

  factory WeeklyAnalytics.fromJson(Map<String, dynamic> json) {
    return WeeklyAnalytics(
      targetProblems: json['targetProblems'] as int? ?? 0,
      targetRevisions: json['targetRevisions'] as int? ?? 0,
      actualProblems: json['actualProblems'] as int? ?? 0,
      actualRevisions: json['actualRevisions'] as int? ?? 0,
      problemsProgress: json['problemsProgress'] as int? ?? 0,
      revisionsProgress: json['revisionsProgress'] as int? ?? 0,
      consistencyScore: json['consistencyScore'] as int? ?? 0,
    );
  }
}
