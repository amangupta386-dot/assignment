import 'package:intl/intl.dart';

import '../../models/daily_plan_model.dart';
import '../../models/pattern_analytics_model.dart';
import '../../models/problem_model.dart';
import '../../models/revision_item.dart';
import '../../models/weekly_analytics_model.dart';
import '../../models/weekly_goal_model.dart';

const String _stageDay1Learn = 'REVISE';
const String _stageDay2ReviseAndSolve = 'SOLVE_AGAIN';
const String _stageDay5SolveWithoutSeeing = 'SOLVE_WITHOUT_SEEING';
const String _stageDay10TimerRevisit = 'FINAL_REVISIT';
const String _stageCompleted = 'COMPLETED';

class LocalFallbackStore {
  LocalFallbackStore._();

  static final LocalFallbackStore instance = LocalFallbackStore._();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  int _problemId = 1;
  int _planId = 1;
  final List<_ProblemRecord> _problems = <_ProblemRecord>[];
  final Map<int, _RevisionRecord> _revisions = <int, _RevisionRecord>{};
  final Map<String, int> _failCountByProblem = <String, int>{};
  final List<DateTime> _revisionCompletions = <DateTime>[];
  final List<WeeklyGoalModel> _timelines = <WeeklyGoalModel>[];
  DailyPlanModel? _todayPlan;
  final Set<String> _activeDays = <String>{};

  List<ProblemModel> getProblems() {
    return _problems
        .map(
          (p) => ProblemModel(
            id: p.id,
            title: p.title,
            platform: p.platform,
            difficulty: p.difficulty,
            pattern: p.pattern,
            initialStatus: p.initialStatus,
          ),
        )
        .toList()
      ..sort((a, b) => b.id.compareTo(a.id));
  }

  void addProblem({
    required String title,
    required String platform,
    required String difficulty,
    required String pattern,
    required String initialStatus,
  }) {
    final now = DateTime.now();
    final id = _problemId++;
    _problems.add(
      _ProblemRecord(
        id: id,
        title: title,
        platform: platform,
        difficulty: difficulty,
        pattern: pattern,
        initialStatus: initialStatus,
        createdAt: now,
      ),
    );

    _revisions[id] = _RevisionRecord(currentStage: _stageDay1Learn, nextReviewDate: _toDate(now));
    _activeDays.add(_toDate(now));
  }

  List<RevisionItem> getTodayRevisions() {
    final today = _toDate(DateTime.now());
    final rows = <RevisionItem>[];

    for (final problem in _problems) {
      final revision = _revisions[problem.id];
      if (revision == null) continue;
      if (revision.currentStage == _stageDay1Learn || revision.currentStage == _stageCompleted) continue;
      if (revision.nextReviewDate.compareTo(today) > 0) continue;

      rows.add(
        RevisionItem(
          problemId: problem.id,
          title: problem.title,
          pattern: problem.pattern,
          currentStage: revision.currentStage,
          nextReviewDate: revision.nextReviewDate,
        ),
      );
    }

    rows.sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
    return rows;
  }

  void completeRevision(int problemId) {
    final revision = _revisions[problemId];
    if (revision == null) return;
    final currentIndex = _stages.indexOf(revision.currentStage);
    final nextIndex = currentIndex < 0 ? 0 : (currentIndex + 1).clamp(0, _stages.length - 1);
    final nextStage = _stages[nextIndex];

    revision.currentStage = nextStage;
    revision.nextReviewDate = nextStage == _stageCompleted
        ? _toDate(DateTime.now())
        : _toDate(DateTime.now().add(Duration(days: _reviewDayOffset(nextStage))));
    _revisionCompletions.add(DateTime.now());
    _activeDays.add(_toDate(DateTime.now()));
  }

  void failRevision(int problemId) {
    final revision = _revisions[problemId];
    if (revision == null) return;
    revision.currentStage = revision.currentStage;
    revision.nextReviewDate = _toDate(DateTime.now());
    _failCountByProblem['$problemId'] = (_failCountByProblem['$problemId'] ?? 0) + 1;
    _activeDays.add(_toDate(DateTime.now()));
  }

  DailyPlanModel getTodayPlan() {
    final today = _toDate(DateTime.now());
    if (_todayPlan != null && _todayPlan!.date == today) return _todayPlan!;
    final assigned = _assignedGoalProblemForDate(DateTime.now());

    _todayPlan = DailyPlanModel(
      id: _planId++,
      date: today,
      dayType: _dayTypeFromWeekday(DateTime.now().weekday),
      status: 'PENDING',
      tasks: <String, dynamic>{
        'problems': <String, dynamic>{'target': 3, 'done': 0},
        'revisions': <String, dynamic>{'target': 5, 'done': 0},
      },
      assignedGoalProblem: assigned,
    );
    return _todayPlan!;
  }

  DailyPlanModel markTaskDone(String key) {
    final plan = getTodayPlan();
    final tasks = Map<String, dynamic>.from(plan.tasks);
    final task = Map<String, dynamic>.from(tasks[key] as Map? ?? const <String, dynamic>{'target': 0, 'done': 0});
    final target = task['target'] as int? ?? 0;
    final done = task['done'] as int? ?? 0;
    task['done'] = done < target ? done + 1 : target;
    tasks[key] = task;

    final completed = tasks.values.whereType<Map>().every((v) {
      final targetValue = v['target'] as int? ?? 0;
      final doneValue = v['done'] as int? ?? 0;
      return doneValue >= targetValue;
    });

    _todayPlan = DailyPlanModel(
      id: plan.id,
      date: plan.date,
      dayType: plan.dayType,
      status: completed ? 'COMPLETED' : 'PENDING',
      tasks: tasks,
      assignedGoalProblem: plan.assignedGoalProblem,
    );
    _promoteDayOneForTodayPlan(plan.date, key);
    return _todayPlan!;
  }

  void upsertWeeklyGoal({
    required String fromDate,
    required String toDate,
    required List<GoalProblemItem> goalProblems,
  }) {
    _timelines.removeWhere((g) => g.fromDate == fromDate && g.toDate == toDate);
    _timelines.add(WeeklyGoalModel(
      fromDate: fromDate,
      toDate: toDate,
      goalProblems: goalProblems,
    ));
    _timelines.sort((a, b) => a.fromDate.compareTo(b.fromDate));
    _todayPlan = null;
  }

  void syncProblemsFromGoal(List<GoalProblemItem> goalProblems) {
    for (final item in goalProblems) {
      final exists = _problems.any(
        (p) =>
            p.title.trim().toLowerCase() == item.problemName.trim().toLowerCase() &&
            p.pattern.trim().toLowerCase() == item.patternName.trim().toLowerCase(),
      );
      if (exists) continue;

      addProblem(
        title: item.problemName,
        platform: 'OTHER',
        difficulty: 'MEDIUM',
        pattern: item.patternName,
        initialStatus: 'NOT_SOLVED',
      );
    }
  }

  WeeklyGoalModel? getCurrentWeeklyGoal() {
    final today = _toDate(DateTime.now());
    final matches = _timelines.where((g) => g.fromDate.compareTo(today) <= 0 && g.toDate.compareTo(today) >= 0).toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.fromDate.compareTo(a.fromDate));
    return matches.first;
  }

  List<WeeklyGoalModel> getMonthlyTimeline(DateTime month) {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    return _timelines.where((g) {
      final from = DateTime.tryParse(g.fromDate);
      final to = DateTime.tryParse(g.toDate);
      if (from == null || to == null) return false;
      return !(to.isBefore(monthStart) || from.isAfter(monthEnd));
    }).toList()
      ..sort((a, b) => a.fromDate.compareTo(b.fromDate));
  }

  WeeklyAnalytics getWeeklyAnalytics() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 6));
    final activeGoal = getCurrentWeeklyGoal();
    final targetProblems = activeGoal?.goalProblems.length ?? 0;
    final targetRevisions = activeGoal?.goalProblems.length ?? 0;

    final actualProblems = _problems.where((p) => !_isBeforeDay(p.createdAt, start) && !_isAfterDay(p.createdAt, end)).length;
    final actualRevisions = _revisionCompletions.where((d) => !_isBeforeDay(d, start) && !_isAfterDay(d, end)).length;
    final activeDays = _activeDays.where((d) {
      final parsed = DateTime.parse(d);
      return !_isBeforeDay(parsed, start) && !_isAfterDay(parsed, end);
    }).length;

    return WeeklyAnalytics(
      targetProblems: targetProblems,
      targetRevisions: targetRevisions,
      actualProblems: actualProblems,
      actualRevisions: actualRevisions,
      problemsProgress: targetProblems == 0 ? 0 : ((actualProblems / targetProblems) * 100).round(),
      revisionsProgress: targetRevisions == 0 ? 0 : ((actualRevisions / targetRevisions) * 100).round(),
      consistencyScore: ((activeDays / 7) * 100).round(),
    );
  }

  List<PatternAnalytics> getPatternAnalytics() {
    final byPattern = <String, Map<String, int>>{};
    for (final problem in _problems) {
      final entry = byPattern.putIfAbsent(problem.pattern, () => <String, int>{'solved': 0, 'failed': 0});
      entry['solved'] = (entry['solved'] ?? 0) + 1;
      entry['failed'] = (entry['failed'] ?? 0) + (_failCountByProblem['${problem.id}'] ?? 0);
    }

    return byPattern.entries.map((entry) {
      final solved = entry.value['solved'] ?? 0;
      final failed = entry.value['failed'] ?? 0;
      final total = solved + failed;
      return PatternAnalytics(
        pattern: entry.key,
        solved: solved,
        failed: failed,
        successRate: total == 0 ? 0 : ((solved / total) * 100).round(),
      );
    }).toList();
  }

  String _toDate(DateTime date) => _dateFormat.format(date);

  bool _isBeforeDay(DateTime left, DateTime right) => DateTime(left.year, left.month, left.day).isBefore(DateTime(right.year, right.month, right.day));
  bool _isAfterDay(DateTime left, DateTime right) => DateTime(left.year, left.month, left.day).isAfter(DateTime(right.year, right.month, right.day));

  GoalProblemItem? _assignedGoalProblemForDate(DateTime date) {
    final dateOnly = _toDate(date);
    final goal = _timelines.where((g) => g.fromDate.compareTo(dateOnly) <= 0 && g.toDate.compareTo(dateOnly) >= 0).fold<WeeklyGoalModel?>(
          null,
          (prev, curr) => prev == null || curr.fromDate.compareTo(prev.fromDate) > 0 ? curr : prev,
        );
    if (goal == null || goal.goalProblems.isEmpty) return null;

    final startDate = DateTime.tryParse(goal.fromDate);
    if (startDate == null) return goal.goalProblems.first;
    final dayOffset = DateTime(date.year, date.month, date.day).difference(DateTime(startDate.year, startDate.month, startDate.day)).inDays;
    final index = dayOffset < 0 ? 0 : dayOffset % goal.goalProblems.length;
    return goal.goalProblems[index];
  }

  void _promoteDayOneForTodayPlan(String date, String key) {
    const problemTaskKeys = <String>{'newProblem', 'deepProblems', 'mockProblems', 'problems'};
    if (!problemTaskKeys.contains(key)) return;

    final goalItem = _assignedGoalProblemForDate(DateTime.parse(date));
    if (goalItem == null) return;

    final match = _problems.where(
      (p) =>
          p.title.trim().toLowerCase() == goalItem.problemName.trim().toLowerCase() &&
          p.pattern.trim().toLowerCase() == goalItem.patternName.trim().toLowerCase(),
    );
    if (match.isEmpty) return;
    final latest = match.reduce((a, b) => a.id > b.id ? a : b);
    final revision = _revisions[latest.id];
    if (revision == null) return;
    if (revision.currentStage != _stageDay1Learn) return;

    revision.currentStage = _stageDay2ReviseAndSolve;
    revision.nextReviewDate = _toDate(DateTime.now().add(const Duration(days: 1)));
  }

  String _dayTypeFromWeekday(int weekday) {
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) return 'HEAVY';
    return 'LIGHT';
  }

  int _reviewDayOffset(String stage) {
    switch (stage) {
      case _stageDay5SolveWithoutSeeing:
        return 3;
      case _stageDay10TimerRevisit:
        return 5;
      default:
        return 0;
    }
  }
}

const List<String> _stages = <String>[
  _stageDay1Learn,
  _stageDay2ReviseAndSolve,
  _stageDay5SolveWithoutSeeing,
  _stageDay10TimerRevisit,
  _stageCompleted,
];

class _ProblemRecord {
  const _ProblemRecord({
    required this.id,
    required this.title,
    required this.platform,
    required this.difficulty,
    required this.pattern,
    required this.initialStatus,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String platform;
  final String difficulty;
  final String pattern;
  final String initialStatus;
  final DateTime createdAt;
}

class _RevisionRecord {
  _RevisionRecord({required this.currentStage, required this.nextReviewDate});

  String currentStage;
  String nextReviewDate;
}
