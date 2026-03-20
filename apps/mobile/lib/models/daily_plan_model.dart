import 'weekly_goal_model.dart';

class DailyPlanModel {
  const DailyPlanModel({
    required this.id,
    required this.date,
    required this.dayType,
    required this.status,
    required this.tasks,
    this.assignedGoalProblem,
    this.weeklyGoalProblems = const [],
    this.dayOneCompleted = false,
    this.assignedProblemCurrentStage,
  });

  final int id;
  final String date;
  final String dayType;
  final String status;
  final Map<String, dynamic> tasks;
  final GoalProblemItem? assignedGoalProblem;
  final List<GoalProblemItem> weeklyGoalProblems;
  final bool dayOneCompleted;
  final String? assignedProblemCurrentStage;

  factory DailyPlanModel.fromJson(Map<String, dynamic> json) {
    return DailyPlanModel(
      id: json['id'] as int,
      date: json['date'] as String,
      dayType: json['dayType'] as String,
      status: json['status'] as String,
      tasks: Map<String, dynamic>.from(json['tasks'] as Map),
      assignedGoalProblem: json['assignedGoalProblem'] == null
          ? null
          : GoalProblemItem.fromJson(
              Map<String, dynamic>.from(json['assignedGoalProblem'] as Map)),
      weeklyGoalProblems:
          (json['weeklyGoalProblems'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map>()
              .map((item) =>
                  GoalProblemItem.fromJson(Map<String, dynamic>.from(item)))
              .toList(),
      dayOneCompleted: json['dayOneCompleted'] as bool? ?? false,
      assignedProblemCurrentStage:
          json['assignedProblemCurrentStage'] as String?,
    );
  }
}
