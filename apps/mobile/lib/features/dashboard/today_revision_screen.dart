import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dsa_prep_coach/features/revision/bloc/revision_bloc.dart';

class TodayRevisionScreen extends StatelessWidget {
  const TodayRevisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today Revisions')),
      body: BlocBuilder<RevisionBloc, RevisionState>(
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) return const Center(child: CircularProgressIndicator());
          if (state.error != null) return Center(child: Text(state.error!));
          if (state.items.isEmpty) return const Center(child: Text('No due revisions today'));

          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('${item.stageLabel} • ${item.pattern} • due ${item.nextReviewDate}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FilledButton(
                            onPressed: () => context.read<RevisionBloc>().add(CompleteRevisionTask(item.problemId)),
                            child: const Text('Done'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => context.read<RevisionBloc>().add(FailRevisionTask(item.problemId)),
                            child: const Text('Fail'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

