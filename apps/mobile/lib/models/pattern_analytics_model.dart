class PatternAnalytics {
  const PatternAnalytics({required this.pattern, required this.solved, required this.failed, required this.successRate});

  final String pattern;
  final int solved;
  final int failed;
  final int successRate;

  factory PatternAnalytics.fromJson(Map<String, dynamic> json) {
    return PatternAnalytics(
      pattern: json['pattern'] as String,
      solved: json['solved'] as int,
      failed: json['failed'] as int,
      successRate: json['successRate'] as int,
    );
  }
}
