import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/widgets/metric_card.dart';
import 'bloc/analytics_bloc.dart';

class WeeklyAnalyticsScreen extends StatelessWidget {
  const WeeklyAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Analytics')),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());
          if (state.error != null) return Center(child: Text(state.error!));
          final weekly = state.weekly;
          if (weekly == null) return const Center(child: Text('No analytics data'));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              MetricCard(label: 'Problems Progress', value: '${weekly.actualProblems}/${weekly.targetProblems}', subtitle: '${weekly.problemsProgress}%'),
              MetricCard(label: 'Revisions Progress', value: '${weekly.actualRevisions}/${weekly.targetRevisions}', subtitle: '${weekly.revisionsProgress}%'),
              MetricCard(label: 'Consistency Score', value: '${weekly.consistencyScore}%'),
              const SizedBox(height: 16),
              Text('Pattern Insights', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...state.patterns.map(
                (p) => ListTile(
                  title: Text(p.pattern),
                  subtitle: Text('Solved ${p.solved} • Failed ${p.failed}'),
                  trailing: Text('${p.successRate}%'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
