class RevisionItem {
  const RevisionItem({
    required this.problemId,
    required this.title,
    required this.pattern,
    required this.currentStage,
    required this.nextReviewDate,
  });

  final int problemId;
  final String title;
  final String pattern;
  final String currentStage;
  final String nextReviewDate;

  String get stageLabel {
    switch (currentStage) {
      case 'REVISE':
        return 'Day 1: Learn about problem';
      case 'SOLVE_AGAIN':
        return 'Day 2: Revise concept and solve problem';
      case 'SOLVE_WITHOUT_SEEING':
        return 'Day 5: Solve problem without seeing';
      case 'FINAL_REVISIT':
        return 'Day 10: Revisit with timer';
      case 'COMPLETED':
        return 'Completed';
      default:
        return currentStage;
    }
  }

  factory RevisionItem.fromJson(Map<String, dynamic> json) {
    final problem = json['Problem'] as Map<String, dynamic>? ?? {};
    return RevisionItem(
      problemId: json['problemId'] as int,
      title: (problem['title'] ?? '-') as String,
      pattern: (problem['pattern'] ?? '-') as String,
      currentStage: json['currentStage'] as String,
      nextReviewDate: json['nextReviewDate'] as String,
    );
  }
}
