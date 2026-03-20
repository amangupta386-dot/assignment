import 'package:intl/intl.dart';

import '../../models/analytics_dashboard_model.dart';
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
  final List<_RevisionCompletionRecord> _revisionCompletions =
      <_RevisionCompletionRecord>[];
  final List<WeeklyGoalModel> _timelines = <WeeklyGoalModel>[];
  DailyPlanModel? _todayPlan;
  final Set<String> _activeDays = <String>{};

  List<ProblemModel> getProblems() {
    return _problems.map(
      (p) {
        final revision = _revisions[p.id];
        final status = revision?.currentStage == _stageCompleted
            ? _stageCompleted
            : p.initialStatus;
        return ProblemModel(
          id: p.id,
          title: p.title,
          platform: p.platform,
          difficulty: p.difficulty,
          pattern: p.pattern,
          initialStatus: status,
        );
      },
    ).toList()
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

    _revisions[id] = _RevisionRecord(
        currentStage: _stageDay1Learn, nextReviewDate: _toDate(now));
    _activeDays.add(_toDate(now));
  }

  List<RevisionItem> getTodayRevisions() {
    final today = _toDate(DateTime.now());
    final rows = <RevisionItem>[];

    for (final problem in _problems) {
      final revision = _revisions[problem.id];
      if (revision == null) continue;
      if (revision.currentStage == _stageDay1Learn ||
          revision.currentStage == _stageCompleted) {
        continue;
      }
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
    final completedStage = revision.currentStage;
    final currentIndex = _stages.indexOf(revision.currentStage);
    final nextIndex =
        currentIndex < 0 ? 0 : (currentIndex + 1).clamp(0, _stages.length - 1);
    final nextStage = _stages[nextIndex];

    revision.currentStage = nextStage;
    revision.nextReviewDate = nextStage == _stageCompleted
        ? _toDate(DateTime.now())
        : _toDate(
            DateTime.now().add(Duration(days: _reviewDayOffset(nextStage))));
    _revisionCompletions.add(
      _RevisionCompletionRecord(
        problemId: problemId,
        stage: completedStage,
        performedAt: DateTime.now(),
      ),
    );
    _activeDays.add(_toDate(DateTime.now()));
  }

  void failRevision(int problemId) {
    final revision = _revisions[problemId];
    if (revision == null) return;
    revision.currentStage = revision.currentStage;
    revision.nextReviewDate = _toDate(DateTime.now());
    _failCountByProblem['$problemId'] =
        (_failCountByProblem['$problemId'] ?? 0) + 1;
    _activeDays.add(_toDate(DateTime.now()));
  }

  DailyPlanModel getTodayPlan() {
    final today = _toDate(DateTime.now());
    if (_todayPlan != null && _todayPlan!.date == today) return _todayPlan!;
    final assigned = _assignedGoalProblemForDate(DateTime.now());
    final activeGoal = getCurrentWeeklyGoal();

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
      weeklyGoalProblems: activeGoal?.goalProblems ?? const <GoalProblemItem>[],
      dayOneCompleted: _isAssignedProblemBeyondDayOne(assigned),
      assignedProblemCurrentStage: _assignedProblemCurrentStage(assigned),
    );
    return _todayPlan!;
  }

  DailyPlanModel markTaskDone(String key) {
    final plan = getTodayPlan();
    final tasks = Map<String, dynamic>.from(plan.tasks);
    final task = Map<String, dynamic>.from(
        tasks[key] as Map? ?? const <String, dynamic>{'target': 0, 'done': 0});
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
      weeklyGoalProblems: plan.weeklyGoalProblems,
      dayOneCompleted: _isAssignedProblemBeyondDayOne(plan.assignedGoalProblem),
      assignedProblemCurrentStage:
          _assignedProblemCurrentStage(plan.assignedGoalProblem),
    );
    _promoteDayOneForTodayPlan(plan.date, key);
    final refreshed = _todayPlan!;
    _todayPlan = DailyPlanModel(
      id: refreshed.id,
      date: refreshed.date,
      dayType: refreshed.dayType,
      status: refreshed.status,
      tasks: refreshed.tasks,
      assignedGoalProblem: refreshed.assignedGoalProblem,
      weeklyGoalProblems: refreshed.weeklyGoalProblems,
      dayOneCompleted:
          _isAssignedProblemBeyondDayOne(refreshed.assignedGoalProblem),
      assignedProblemCurrentStage:
          _assignedProblemCurrentStage(refreshed.assignedGoalProblem),
    );
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
            p.title.trim().toLowerCase() ==
                item.problemName.trim().toLowerCase() &&
            p.pattern.trim().toLowerCase() ==
                item.patternName.trim().toLowerCase(),
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
    final matches = _timelines
        .where((g) =>
            g.fromDate.compareTo(today) <= 0 && g.toDate.compareTo(today) >= 0)
        .toList();
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

    final actualProblems = _problems
        .where((p) =>
            !_isBeforeDay(p.createdAt, start) && !_isAfterDay(p.createdAt, end))
        .length;
    final actualRevisions = _revisionCompletions
        .where((d) =>
            !_isBeforeDay(d.performedAt, start) &&
            !_isAfterDay(d.performedAt, end))
        .length;
    final activeDays = _activeDays.where((d) {
      final parsed = DateTime.parse(d);
      return !_isBeforeDay(parsed, start) && !_isAfterDay(parsed, end);
    }).length;

    return WeeklyAnalytics(
      targetProblems: targetProblems,
      targetRevisions: targetRevisions,
      actualProblems: actualProblems,
      actualRevisions: actualRevisions,
      problemsProgress: targetProblems == 0
          ? 0
          : ((actualProblems / targetProblems) * 100).round(),
      revisionsProgress: targetRevisions == 0
          ? 0
          : ((actualRevisions / targetRevisions) * 100).round(),
      consistencyScore: ((activeDays / 7) * 100).round(),
    );
  }

  List<PatternAnalytics> getPatternAnalytics() {
    final byPattern = <String, Map<String, int>>{};
    for (final problem in _problems) {
      final entry = byPattern.putIfAbsent(
          problem.pattern, () => <String, int>{'solved': 0, 'failed': 0});
      entry['solved'] = (entry['solved'] ?? 0) + 1;
      entry['failed'] =
          (entry['failed'] ?? 0) + (_failCountByProblem['${problem.id}'] ?? 0);
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

  AnalyticsDashboard getAnalyticsDashboard() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final monthStart = DateTime(today.year, today.month, 1);
    final monthEnd = DateTime(today.year, today.month + 1, 0);

    final dailyCompletion = _buildCompletionMap(today, today);
    final weeklyCompletion = _buildCompletionMap(weekStart, weekEnd);
    final monthlyCompletion = _buildCompletionMap(monthStart, monthEnd);

    final dailyStageMetrics = _stageDefinitions
        .map(
          (stage) => StageMetric(
            stageKey: stage.key,
            title: stage.title,
            shortLabel: stage.shortLabel,
            description: stage.description,
            due: _dueCount(stage.key, today),
            completed: dailyCompletion[stage.key] ?? 0,
            overdue: _overdueCount(stage.key, today),
            backlog: _backlogCount(stage.key),
          ),
        )
        .toList();

    final weeklyStageMetrics = _stageDefinitions
        .map(
          (stage) => StageMetric(
            stageKey: stage.key,
            title: stage.title,
            shortLabel: stage.shortLabel,
            description: stage.description,
            due: _dueCount(stage.key, weekEnd),
            completed: weeklyCompletion[stage.key] ?? 0,
            overdue: _overdueCount(stage.key, today),
            backlog: _backlogCount(stage.key),
          ),
        )
        .toList();

    final monthlyStageMetrics = _stageDefinitions
        .map(
          (stage) => StageMetric(
            stageKey: stage.key,
            title: stage.title,
            shortLabel: stage.shortLabel,
            description: stage.description,
            due: _dueCount(stage.key, today),
            completed: monthlyCompletion[stage.key] ?? 0,
            overdue: _overdueCount(stage.key, today),
            backlog: _backlogCount(stage.key),
          ),
        )
        .toList();

    final dailyTotalCompleted =
        dailyCompletion.values.fold<int>(0, (sum, value) => sum + value);
    final dailyTotalDue =
        dailyStageMetrics.fold<int>(0, (sum, value) => sum + value.due);
    final weeklyTotalCompleted =
        weeklyCompletion.values.fold<int>(0, (sum, value) => sum + value);
    final monthlyTotalCompleted =
        monthlyCompletion.values.fold<int>(0, (sum, value) => sum + value);

    final activeGoal = getCurrentWeeklyGoal();
    final targetProblems = activeGoal?.goalProblems.length ?? 0;
    final targetRevisions = activeGoal?.goalProblems.length ?? 0;
    final actualProblems = _problems
        .where((p) =>
            !_isBeforeDay(p.createdAt, weekStart) &&
            !_isAfterDay(p.createdAt, weekEnd))
        .length;
    final actualRevisions = _revisionCompletions
        .where((d) =>
            !_isBeforeDay(d.performedAt, weekStart) &&
            !_isAfterDay(d.performedAt, weekEnd))
        .length;

    return AnalyticsDashboard(
      generatedOn: now.toIso8601String(),
      daily: AnalyticsPeriod(
        label: _toDate(today),
        totalDue: dailyTotalDue,
        totalCompleted: dailyTotalCompleted,
        overdue:
            dailyStageMetrics.fold<int>(0, (sum, value) => sum + value.overdue),
        completionScore: dailyTotalDue + dailyTotalCompleted == 0
            ? 0
            : ((dailyTotalCompleted / (dailyTotalDue + dailyTotalCompleted)) *
                    100)
                .round(),
        stageMetrics: dailyStageMetrics,
      ),
      weekly: AnalyticsWeek(
        label: '${_toDate(weekStart)} to ${_toDate(weekEnd)}',
        activeDays: _activeDayCount(weekStart, weekEnd),
        consistencyScore:
            ((_activeDayCount(weekStart, weekEnd) / 7) * 100).round(),
        totalCompleted: weeklyTotalCompleted,
        fullCycleCompleted: weeklyCompletion[_stageDay10TimerRevisit] ?? 0,
        stageMetrics: weeklyStageMetrics,
        goalProgress: GoalProgress(
          targetProblems: targetProblems,
          targetRevisions: targetRevisions,
          actualProblems: actualProblems,
          actualRevisions: actualRevisions,
          problemsProgress: targetProblems == 0
              ? 0
              : ((actualProblems / targetProblems) * 100).round(),
          revisionsProgress: targetRevisions == 0
              ? 0
              : ((actualRevisions / targetRevisions) * 100).round(),
        ),
      ),
      monthly: AnalyticsMonth(
        label: DateFormat('MMMM yyyy').format(today),
        activeDays: _activeDayCount(monthStart, monthEnd),
        totalCompleted: monthlyTotalCompleted,
        fullCycleCompleted: monthlyCompletion[_stageDay10TimerRevisit] ?? 0,
        totalProblemsStarted: _problems
            .where((p) =>
                !_isBeforeDay(p.createdAt, monthStart) &&
                !_isAfterDay(p.createdAt, monthEnd))
            .length,
        stageMetrics: monthlyStageMetrics,
        weekBreakdown: _buildMonthlyWeekBreakdown(monthStart, monthEnd),
      ),
      patterns: getPatternAnalytics()
          .map(
            (item) => PatternInsight(
              pattern: item.pattern,
              solved: item.solved,
              failed: item.failed,
              successRate: item.successRate,
            ),
          )
          .toList(),
    );
  }

  String _toDate(DateTime date) => _dateFormat.format(date);

  bool _isBeforeDay(DateTime left, DateTime right) =>
      DateTime(left.year, left.month, left.day)
          .isBefore(DateTime(right.year, right.month, right.day));
  bool _isAfterDay(DateTime left, DateTime right) =>
      DateTime(left.year, left.month, left.day)
          .isAfter(DateTime(right.year, right.month, right.day));

  GoalProblemItem? _assignedGoalProblemForDate(DateTime date) {
    final dateOnly = _toDate(date);
    final goal = _timelines
        .where((g) =>
            g.fromDate.compareTo(dateOnly) <= 0 &&
            g.toDate.compareTo(dateOnly) >= 0)
        .fold<WeeklyGoalModel?>(
          null,
          (prev, curr) =>
              prev == null || curr.fromDate.compareTo(prev.fromDate) > 0
                  ? curr
                  : prev,
        );
    if (goal == null || goal.goalProblems.isEmpty) return null;

    final startDate = DateTime.tryParse(goal.fromDate);
    if (startDate == null) return goal.goalProblems.first;
    final dayOffset = DateTime(date.year, date.month, date.day)
        .difference(DateTime(startDate.year, startDate.month, startDate.day))
        .inDays;
    final index = dayOffset < 0 ? 0 : dayOffset % goal.goalProblems.length;
    return goal.goalProblems[index];
  }

  void _promoteDayOneForTodayPlan(String date, String key) {
    const problemTaskKeys = <String>{
      'newProblem',
      'deepProblems',
      'mockProblems',
      'problems'
    };
    if (!problemTaskKeys.contains(key)) return;

    final goalItem = _assignedGoalProblemForDate(DateTime.parse(date));
    if (goalItem == null) return;

    final match = _problems.where(
      (p) =>
          p.title.trim().toLowerCase() ==
              goalItem.problemName.trim().toLowerCase() &&
          p.pattern.trim().toLowerCase() ==
              goalItem.patternName.trim().toLowerCase(),
    );
    if (match.isEmpty) return;
    final latest = match.reduce((a, b) => a.id > b.id ? a : b);
    final revision = _revisions[latest.id];
    if (revision == null) return;
    if (revision.currentStage != _stageDay1Learn) return;

    revision.currentStage = _stageDay2ReviseAndSolve;
    revision.nextReviewDate =
        _toDate(DateTime.now().add(const Duration(days: 1)));
    _revisionCompletions.add(
      _RevisionCompletionRecord(
        problemId: latest.id,
        stage: _stageDay1Learn,
        performedAt: DateTime.now(),
      ),
    );
  }

  String _dayTypeFromWeekday(int weekday) {
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      return 'HEAVY';
    }
    return 'LIGHT';
  }

  bool _isAssignedProblemBeyondDayOne(GoalProblemItem? assigned) {
    final stage = _assignedProblemCurrentStage(assigned);
    if (stage == null) return false;
    return stage != _stageDay1Learn;
  }

  String? _assignedProblemCurrentStage(GoalProblemItem? assigned) {
    if (assigned == null) return null;
    final matchingProblems = _problems.where(
      (p) =>
          p.title.trim().toLowerCase() ==
              assigned.problemName.trim().toLowerCase() &&
          p.pattern.trim().toLowerCase() ==
              assigned.patternName.trim().toLowerCase(),
    );
    if (matchingProblems.isEmpty) return null;

    final latest = matchingProblems.reduce((a, b) => a.id > b.id ? a : b);
    return _revisions[latest.id]?.currentStage;
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

  Map<String, int> _buildCompletionMap(DateTime start, DateTime end) {
    final map = <String, int>{
      _stageDay1Learn: 0,
      _stageDay2ReviseAndSolve: 0,
      _stageDay5SolveWithoutSeeing: 0,
      _stageDay10TimerRevisit: 0,
    };

    for (final record in _revisionCompletions) {
      if (_isBeforeDay(record.performedAt, start) ||
          _isAfterDay(record.performedAt, end)) {
        continue;
      }
      if (map.containsKey(record.stage)) {
        map[record.stage] = (map[record.stage] ?? 0) + 1;
      }
    }
    return map;
  }

  int _dueCount(String stage, DateTime cutoff) {
    return _revisions.values
        .where((revision) =>
            revision.currentStage == stage &&
            revision.nextReviewDate.compareTo(_toDate(cutoff)) <= 0)
        .length;
  }

  int _overdueCount(String stage, DateTime cutoff) {
    return _revisions.values
        .where((revision) =>
            revision.currentStage == stage &&
            revision.nextReviewDate.compareTo(_toDate(cutoff)) < 0)
        .length;
  }

  int _backlogCount(String stage) {
    return _revisions.values
        .where((revision) => revision.currentStage == stage)
        .length;
  }

  int _activeDayCount(DateTime start, DateTime end) {
    return _activeDays.where((value) {
      final parsed = DateTime.parse(value);
      return !_isBeforeDay(parsed, start) && !_isAfterDay(parsed, end);
    }).length;
  }

  List<MonthlyWeekBreakdown> _buildMonthlyWeekBreakdown(
      DateTime start, DateTime end) {
    final weeks = <MonthlyWeekBreakdown>[];
    var cursor = start;
    var weekIndex = 1;

    while (!_isAfterDay(cursor, end)) {
      final weekStart = cursor;
      final weekEnd = DateTime(
        cursor.year,
        cursor.month,
        cursor.day + 6,
      );
      final boundedEnd = _isAfterDay(weekEnd, end) ? end : weekEnd;
      final completion = _buildCompletionMap(weekStart, boundedEnd);
      final stageMetrics = _stageDefinitions
          .map(
            (stage) => StageMetric(
              stageKey: stage.key,
              title: stage.title,
              shortLabel: stage.shortLabel,
              description: stage.description,
              due: 0,
              completed: completion[stage.key] ?? 0,
              overdue: 0,
              backlog: 0,
            ),
          )
          .toList();

      weeks.add(
        MonthlyWeekBreakdown(
          label: 'Week $weekIndex',
          startDate: _toDate(weekStart),
          endDate: _toDate(boundedEnd),
          totalCompleted:
              completion.values.fold<int>(0, (sum, value) => sum + value),
          stageMetrics: stageMetrics,
        ),
      );

      cursor = DateTime(cursor.year, cursor.month, cursor.day + 7);
      weekIndex += 1;
    }

    return weeks;
  }
}

const List<String> _stages = <String>[
  _stageDay1Learn,
  _stageDay2ReviseAndSolve,
  _stageDay5SolveWithoutSeeing,
  _stageDay10TimerRevisit,
  _stageCompleted,
];

const List<_StageDefinition> _stageDefinitions = <_StageDefinition>[
  _StageDefinition(
    key: _stageDay1Learn,
    title: 'Learn About Problem',
    shortLabel: 'Stage 1',
    description: 'Learn the problem and understand the approach.',
  ),
  _StageDefinition(
    key: _stageDay2ReviseAndSolve,
    title: 'Revise And Solve',
    shortLabel: 'Stage 2',
    description: 'Revisit the concept and solve the problem again.',
  ),
  _StageDefinition(
    key: _stageDay5SolveWithoutSeeing,
    title: 'Solve Without Seeing',
    shortLabel: 'Stage 3',
    description: 'Solve the problem independently without looking.',
  ),
  _StageDefinition(
    key: _stageDay10TimerRevisit,
    title: 'Revisit With Timer',
    shortLabel: 'Stage 4',
    description: 'Revisit the problem under timed conditions.',
  ),
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

class _RevisionCompletionRecord {
  const _RevisionCompletionRecord({
    required this.problemId,
    required this.stage,
    required this.performedAt,
  });

  final int problemId;
  final String stage;
  final DateTime performedAt;
}

class _StageDefinition {
  const _StageDefinition({
    required this.key,
    required this.title,
    required this.shortLabel,
    required this.description,
  });

  final String key;
  final String title;
  final String shortLabel;
  final String description;
}
