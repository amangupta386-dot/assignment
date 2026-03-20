import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'bloc/plan_bloc.dart';

class TodayPlanScreen extends StatelessWidget {
  const TodayPlanScreen({super.key});

  String _stageLabel(String? stage) {
    switch (stage) {
      case 'REVISE':
        return 'Learn about problem';
      case 'SOLVE_AGAIN':
        return 'Revise concept and solve again';
      case 'SOLVE_WITHOUT_SEEING':
        return 'Solve without seeing';
      case 'FINAL_REVISIT':
        return 'Revisit with timer';
      case 'COMPLETED':
        return 'Completed';
      default:
        return 'Not started';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Today Plan')),
      body: SelectionArea(
        child: BlocBuilder<PlanBloc, PlanState>(
          builder: (context, state) {
            if (state.isLoading && state.plan == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text(state.error!));
            }
            final plan = state.plan;
            if (plan == null) {
              return const Center(child: Text('No plan available'));
            }

            const hiddenTaskKeys = <String>{
              'newProblem',
              'deepProblems',
              'patternNotes',
              'patternRevision',
              'revisionProblem',
            };
            final entries = plan.tasks.entries
                .where((e) => e.value is Map && !hiddenTaskKeys.contains(e.key))
                .toList();
            const problemTaskKeys = <String>[
              'newProblem',
              'deepProblems',
              'mockProblems',
              'problems'
            ];
            String? dayOneTaskKey;
            for (final key in problemTaskKeys) {
              if (plan.tasks[key] is Map) {
                dayOneTaskKey = key;
                break;
              }
            }

            bool dayOneAlreadyDone = false;
            if (dayOneTaskKey != null) {
              final data =
                  Map<String, dynamic>.from(plan.tasks[dayOneTaskKey] as Map);
              dayOneAlreadyDone = (data['done'] as int? ?? 0) > 0;
            }
            dayOneAlreadyDone = dayOneAlreadyDone || plan.dayOneCompleted;
            final dayTwoDueDate = DateFormat('yyyy-MM-dd')
                .format(DateTime.now().add(const Duration(days: 1)));
            final extraGoalProblems = plan.weeklyGoalProblems
                .where((item) =>
                    plan.assignedGoalProblem == null ||
                    item.problemName != plan.assignedGoalProblem!.problemName ||
                    item.patternName != plan.assignedGoalProblem!.patternName)
                .toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF155E75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Focus For Today',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start with your assigned problem, then use the extra weekly goal questions if you still have more time and energy.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _PlanStatTile(
                            label: 'Day Type',
                            value: _prettyDayType(plan.dayType),
                          ),
                          _PlanStatTile(
                            label: 'Status',
                            value: _prettyStatus(plan.status),
                          ),
                          _PlanStatTile(
                            label: 'Goal Qs',
                            value: '${plan.weeklyGoalProblems.length}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (plan.assignedGoalProblem != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.track_changes_outlined,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Main Question',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Start here before moving to extra weekly questions.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          plan.assignedGoalProblem!.problemName,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _PlanChip(
                              icon: Icons.hub_outlined,
                              label: plan.assignedGoalProblem!.patternName,
                            ),
                            _PlanChip(
                              icon: dayOneAlreadyDone
                                  ? Icons.check_circle
                                  : Icons.timelapse_outlined,
                              label: dayOneAlreadyDone
                                  ? 'Day 1 done'
                                  : 'Pending today',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed:
                                (dayOneTaskKey == null || dayOneAlreadyDone)
                                    ? null
                                    : () => context
                                        .read<PlanBloc>()
                                        .add(MarkTaskDone(dayOneTaskKey!)),
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              dayOneAlreadyDone
                                  ? 'Day 1 Completed'
                                  : 'Mark Day 1 Done',
                            ),
                          ),
                        ),
                        if (dayOneAlreadyDone) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Next stage scheduled for $dayTwoDueDate',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Current Revision Stage: ${_stageLabel(plan.assignedProblemCurrentStage)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (extraGoalProblems.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'More Questions From This Week',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  ...extraGoalProblems.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.bolt_outlined,
                              color: colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.problemName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                _PlanChip(
                                  icon: Icons.auto_awesome_outlined,
                                  label: item.patternName,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Daily Tasks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                if (entries.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.done_all_outlined,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No extra daily tasks visible right now.',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Start with the main question above, then use the extra weekly goal problems if you still have more study time today.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  )
                else
                  ...entries.map((entry) {
                    final data = Map<String, dynamic>.from(entry.value as Map);
                    final target = data['target'] as int? ?? 0;
                    final done = data['done'] as int? ?? 0;
                    final progress = target == 0
                        ? 0.0
                        : (done / target).clamp(0, 1).toDouble();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _taskTitle(entry.key),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '$done / $target',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => context
                                  .read<PlanBloc>()
                                  .add(MarkTaskDone(entry.key)),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Update'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }

  String _taskTitle(String key) {
    switch (key) {
      case 'problems':
        return 'Practice Problems';
      case 'revisions':
        return 'Revision Queue';
      case 'mockProblems':
        return 'Mock Problems';
      default:
        return key;
    }
  }

  String _prettyDayType(String value) {
    switch (value) {
      case 'SATURDAY':
        return 'Saturday';
      case 'SUNDAY':
        return 'Sunday';
      case 'WEEKDAY':
        return 'Weekday';
      default:
        return value;
    }
  }

  String _prettyStatus(String value) {
    switch (value) {
      case 'PENDING':
        return 'Pending';
      case 'COMPLETED':
        return 'Completed';
      default:
        return value;
    }
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _PlanStatTile extends StatelessWidget {
  const _PlanStatTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
