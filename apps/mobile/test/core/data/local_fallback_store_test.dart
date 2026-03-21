import 'package:dsa_prep_coach/core/data/local_fallback_store.dart';
import 'package:dsa_prep_coach/models/weekly_goal_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final store = LocalFallbackStore.instance;
  late DateTime currentNow;

  setUp(() {
    currentNow = DateTime(2026, 3, 18, 9);
    store.resetForTesting(nowProvider: () => currentNow);
  });

  tearDown(() {
    store.resetForTesting();
  });

  test('today plan assigns current week problem and promotes day 1 completion', () {
    final goalProblems = <GoalProblemItem>[
      const GoalProblemItem(
        problemName: 'Two Sum',
        patternName: 'Hashing',
        timeComplexity: 'O(n)',
      ),
      const GoalProblemItem(
        problemName: 'Product of Array Except Self',
        patternName: 'Prefix Sum',
        timeComplexity: 'O(n)',
      ),
      const GoalProblemItem(
        problemName: 'Majority Element',
        patternName: 'Moore Voting',
        timeComplexity: 'O(n)',
      ),
    ];

    store.upsertWeeklyGoal(
      fromDate: '2026-03-16',
      toDate: '2026-03-22',
      goalProblems: goalProblems,
    );
    store.syncProblemsFromGoal(goalProblems);

    final todayPlan = store.getTodayPlan();
    expect(todayPlan.assignedGoalProblem?.problemName, 'Majority Element');
    expect(todayPlan.dayOneCompleted, isFalse);
    expect(todayPlan.assignedProblemCurrentStage, 'REVISE');

    final updatedPlan = store.markTaskDone('problems');
    expect(updatedPlan.dayOneCompleted, isTrue);
    expect(updatedPlan.assignedProblemCurrentStage, 'SOLVE_AGAIN');

    currentNow = DateTime(2026, 3, 19, 9);
    final revisions = store.getTodayRevisions();
    expect(revisions, hasLength(1));
    expect(revisions.single.title, 'Majority Element');
    expect(revisions.single.currentStage, 'SOLVE_AGAIN');
  });

  test('planning insights recommend next target from last week performance', () {
    final goalProblems = <GoalProblemItem>[
      const GoalProblemItem(
        problemName: 'Problem 1',
        patternName: 'Array',
        timeComplexity: 'O(n)',
      ),
      const GoalProblemItem(
        problemName: 'Problem 2',
        patternName: 'Hashing',
        timeComplexity: 'O(n)',
      ),
      const GoalProblemItem(
        problemName: 'Problem 3',
        patternName: 'Sliding Window',
        timeComplexity: 'O(n)',
      ),
      const GoalProblemItem(
        problemName: 'Problem 4',
        patternName: 'Heap',
        timeComplexity: 'O(log n)',
      ),
    ];

    store.upsertWeeklyGoal(
      fromDate: '2026-03-09',
      toDate: '2026-03-15',
      goalProblems: goalProblems,
    );
    store.syncProblemsFromGoal(goalProblems);

    currentNow = DateTime(2026, 3, 9, 9);
    store.markTaskDone('problems');
    currentNow = DateTime(2026, 3, 10, 9);
    store.markTaskDone('problems');
    currentNow = DateTime(2026, 3, 11, 9);
    store.markTaskDone('problems');

    currentNow = DateTime(2026, 3, 18, 9);
    final insights = store.getWeeklyGoalPlanningInsights();

    expect(insights.recommendedTarget, 4);
    expect(insights.suggestedNewProblems, 3);
    expect(insights.carryForwardProblems, hasLength(1));
    expect(insights.carryForwardProblems.single.problemName, 'Problem 4');
    expect(insights.lastWeek.completedDayOneCount, 3);
    expect(insights.lastWeek.completionRate, 75);
  });

  test('completed revisions mark the problem as completed in the problem list', () {
    store.addProblem(
      title: 'Binary Search',
      platform: 'OTHER',
      difficulty: 'MEDIUM',
      pattern: 'Binary Search',
      timeComplexity: 'O(log n)',
      initialStatus: 'NOT_SOLVED',
    );

    final problemId = store.getProblems().single.id;

    store.completeRevision(problemId);
    store.completeRevision(problemId);
    store.completeRevision(problemId);
    store.completeRevision(problemId);

    expect(store.getProblems().single.initialStatus, 'COMPLETED');
  });
}
