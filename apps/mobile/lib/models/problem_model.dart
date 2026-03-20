class ProblemModel {
  const ProblemModel({
    required this.id,
    required this.title,
    required this.platform,
    required this.difficulty,
    required this.pattern,
    required this.initialStatus,
  });

  final int id;
  final String title;
  final String platform;
  final String difficulty;
  final String pattern;
  final String initialStatus;

  factory ProblemModel.fromJson(Map<String, dynamic> json) {
    return ProblemModel(
      id: json['id'] as int,
      title: json['title'] as String,
      platform: json['platform'] as String,
      difficulty: json['difficulty'] as String,
      pattern: json['pattern'] as String,
      initialStatus: json['initialStatus'] as String? ?? 'SOLVED',
    );
  }
}
