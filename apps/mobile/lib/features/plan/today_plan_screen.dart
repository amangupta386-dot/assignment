import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/plan_bloc.dart';

class TodayPlanScreen extends StatelessWidget {
  const TodayPlanScreen({super.key});

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
                    subtitle: Text(plan.assignedGoalProblem!.patternName),
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

