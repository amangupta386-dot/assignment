class PatternNoteModel {
  const PatternNoteModel({
    required this.patternName,
    required this.imagePath,
    required this.updatedAt,
  });

  final String patternName;
  final String imagePath;
  final String updatedAt;

  String get normalizedPattern => normalizePattern(patternName);

  factory PatternNoteModel.fromJson(Map<String, dynamic> json) {
    return PatternNoteModel(
      patternName: (json['patternName'] ?? '').toString(),
      imagePath: (json['imagePath'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'patternName': patternName,
      'imagePath': imagePath,
      'updatedAt': updatedAt,
    };
  }

  PatternNoteModel copyWith({
    String? patternName,
    String? imagePath,
    String? updatedAt,
  }) {
    return PatternNoteModel(
      patternName: patternName ?? this.patternName,
      imagePath: imagePath ?? this.imagePath,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String normalizePattern(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
