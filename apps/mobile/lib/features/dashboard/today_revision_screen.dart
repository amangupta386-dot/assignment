import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dsa_prep_coach/features/revision/bloc/revision_bloc.dart';
import 'package:dsa_prep_coach/models/revision_item.dart';

class TodayRevisionScreen extends StatelessWidget {
  const TodayRevisionScreen({super.key});

  static const List<_StageMeta> _stages = <_StageMeta>[
    _StageMeta(
        key: 'REVISE', title: 'Day 1', description: 'Learn about problem'),
    _StageMeta(
        key: 'SOLVE_AGAIN',
        title: 'Day 2',
        description: 'Revise the concept and solve problem'),
    _StageMeta(
        key: 'SOLVE_WITHOUT_SEEING',
        title: 'Day 5',
        description: 'Solve problem without seeing'),
    _StageMeta(
        key: 'FINAL_REVISIT',
        title: 'Day 10',
        description: 'Revisit with timer'),
  ];

  bool _isDueToday(String date) {
    final due = DateTime.tryParse(date);
    if (due == null) return false;
    final now = DateTime.now();
    return due.year == now.year && due.month == now.month && due.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today Revisions')),
      body: SelectionArea(
        child: BlocBuilder<RevisionBloc, RevisionState>(
          builder: (context, state) {
            if (state.isLoading && state.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) return Center(child: Text(state.error!));
            if (state.items.isEmpty) {
              return const Center(
                  child: Text('No revision stages in the next 10 days'));
            }

            final byStage = <String, List<RevisionItem>>{};
            for (final stage in _stages) {
              byStage[stage.key] = <RevisionItem>[];
            }
            for (final item in state.items) {
              if (byStage.containsKey(item.currentStage)) {
                byStage[item.currentStage]!.add(item);
              }
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: _stages.map((stage) {
                final stageItems = byStage[stage.key] ?? const <RevisionItem>[];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD9E2EC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${stage.title}: ${stage.description}',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      if (stageItems.isEmpty)
                        Text('No problems in this stage',
                            style: Theme.of(context).textTheme.bodySmall)
                      else
                        ...stageItems.map(
                          (item) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE6EDF5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title,
                                    style:
                                        Theme.of(context).textTheme.titleSmall),
                                const SizedBox(height: 4),
                                Text('Pattern: ${item.pattern}'),
                                const SizedBox(height: 4),
                                Text(_isDueToday(item.nextReviewDate)
                                    ? 'Due: Today'
                                    : 'Due: ${item.nextReviewDate}'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    FilledButton(
                                      onPressed: () => context
                                          .read<RevisionBloc>()
                                          .add(CompleteRevisionTask(
                                              item.problemId)),
                                      child: const Text('Done'),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () => context
                                          .read<RevisionBloc>()
                                          .add(
                                              FailRevisionTask(item.problemId)),
                                      child: const Text('Fail'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _StageMeta {
  const _StageMeta({
    required this.key,
    required this.title,
    required this.description,
  });

  final String key;
  final String title;
  final String description;
}
