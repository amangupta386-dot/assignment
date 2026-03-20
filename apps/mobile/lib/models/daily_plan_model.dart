class DailyPlanModel {
  const DailyPlanModel({
    required this.id,
    required this.date,
    required this.dayType,
    required this.status,
    required this.tasks,
  });

  final int id;
  final String date;
  final String dayType;
  final String status;
  final Map<String, dynamic> tasks;

  factory DailyPlanModel.fromJson(Map<String, dynamic> json) {
    return DailyPlanModel(
      id: json['id'] as int,
      date: json['date'] as String,
      dayType: json['dayType'] as String,
      status: json['status'] as String,
      tasks: Map<String, dynamic>.from(json['tasks'] as Map),
    );
  }
}
