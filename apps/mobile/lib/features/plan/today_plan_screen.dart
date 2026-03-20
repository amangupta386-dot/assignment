import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'bloc/plan_bloc.dart';

class TodayPlanScreen extends StatelessWidget {
  const TodayPlanScreen({super.key});

  String _stageLabel(String? stage) {
    switch (stage) {
      case 'REVISE':
        return 'Day 1: Learn about problem';
      case 'SOLVE_AGAIN':
        return 'Day 2: Revise the concept and solve problem';
      case 'SOLVE_WITHOUT_SEEING':
        return 'Day 5: Solve problem without seeing';
      case 'FINAL_REVISIT':
        return 'Day 10: Revisit with timer';
      case 'COMPLETED':
        return 'Completed';
      default:
        return 'Not started';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today Plan')),
      body: BlocBuilder<PlanBloc, PlanState>(
        builder: (context, state) {
          if (state.isLoading && state.plan == null) return const Center(child: CircularProgressIndicator());
          if (state.error != null) return Center(child: Text(state.error!));
          final plan = state.plan;
          if (plan == null) return const Center(child: Text('No plan available'));

          final entries = plan.tasks.entries.where((e) => e.value is Map).toList();
          const problemTaskKeys = <String>['newProblem', 'deepProblems', 'mockProblems', 'problems'];
          String? dayOneTaskKey;
          for (final key in problemTaskKeys) {
            if (plan.tasks[key] is Map) {
              dayOneTaskKey = key;
              break;
            }
          }
          bool dayOneAlreadyDone = false;
          if (dayOneTaskKey != null) {
            final data = Map<String, dynamic>.from(plan.tasks[dayOneTaskKey] as Map);
            dayOneAlreadyDone = (data['done'] as int? ?? 0) > 0;
          }
          dayOneAlreadyDone = dayOneAlreadyDone || plan.dayOneCompleted;
          final dayTwoDueDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Day Type: ${plan.dayType}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Status: ${plan.status}'),
              if (plan.assignedGoalProblem != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    title: Text(plan.assignedGoalProblem!.problemName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.assignedGoalProblem!.patternName),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: (dayOneTaskKey == null || dayOneAlreadyDone)
                              ? null
                              : () => context.read<PlanBloc>().add(MarkTaskDone(dayOneTaskKey!)),
                          child: Text(dayOneAlreadyDone ? 'Day 1 Completed' : 'Mark Day 1 Done'),
                        ),
                        if (dayOneAlreadyDone) ...[
                          const SizedBox(height: 6),
                          Text('Stage 2 is scheduled for $dayTwoDueDate'),
                          const SizedBox(height: 4),
                          Text('Current Revision Stage: ${_stageLabel(plan.assignedProblemCurrentStage)}'),
                        ],
                      ],
                    ),
                    leading: const Icon(Icons.flag_outlined),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ...entries.map((entry) {
                final data = Map<String, dynamic>.from(entry.value as Map);
                final target = data['target'] as int? ?? 0;
                final done = data['done'] as int? ?? 0;
                return Card(
                  child: ListTile(
                    title: Text(entry.key),
                    subtitle: Text('Done $done / $target'),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () => context.read<PlanBloc>().add(MarkTaskDone(entry.key)),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}


