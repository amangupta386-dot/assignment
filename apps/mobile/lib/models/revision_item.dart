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
