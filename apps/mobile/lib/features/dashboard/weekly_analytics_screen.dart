import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dsa_prep_coach/features/analytics/bloc/analytics_bloc.dart';
import 'package:dsa_prep_coach/models/analytics_dashboard_model.dart';

class WeeklyAnalyticsScreen extends StatelessWidget {
  const WeeklyAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),
        body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            if (state.isLoading && state.dashboard == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SelectionArea(
                    child: SelectableText(state.error!),
                  ),
                ),
              );
            }
            final dashboard = state.dashboard;
            if (dashboard == null) {
              return const Center(child: Text('No analytics data'));
            }

            return Column(
              children: [
                _AnalyticsHero(dashboard: dashboard),
                const Expanded(
                  child: TabBarView(
                    children: [
                      _DailyTab(),
                      _WeeklyTab(),
                      _MonthlyTab(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AnalyticsHero extends StatelessWidget {
  const _AnalyticsHero({required this.dashboard});

  final AnalyticsDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
            'Track every revision stage',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Daily focus, weekly consistency, and monthly depth across all 4 learning stages.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'Today',
                  value: '${dashboard.daily.completionScore}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroMetric(
                  label: 'Week',
                  value: '${dashboard.weekly.consistencyScore}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroMetric(
                  label: 'Month',
                  value: '${dashboard.monthly.totalCompleted}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyTab extends StatelessWidget {
  const _DailyTab();

  @override
  Widget build(BuildContext context) {
    final dashboard =
        context.select((AnalyticsBloc bloc) => bloc.state.dashboard)!;
    final daily = dashboard.daily;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Text(daily.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _SummaryGrid(
          metrics: [
            _SummaryItem(label: 'Due Today', value: '${daily.totalDue}'),
            _SummaryItem(label: 'Completed', value: '${daily.totalCompleted}'),
            _SummaryItem(label: 'Overdue', value: '${daily.overdue}'),
            _SummaryItem(label: 'Score', value: '${daily.completionScore}%'),
          ],
        ),
        const SizedBox(height: 16),
        ...daily.stageMetrics.map((metric) =>
            _StageCard(metric: metric, accent: const Color(0xFF0F766E))),
      ],
    );
  }
}

class _WeeklyTab extends StatelessWidget {
  const _WeeklyTab();

  @override
  Widget build(BuildContext context) {
    final dashboard =
        context.select((AnalyticsBloc bloc) => bloc.state.dashboard)!;
    final weekly = dashboard.weekly;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Text(weekly.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _SummaryGrid(
          metrics: [
            _SummaryItem(label: 'Active Days', value: '${weekly.activeDays}/7'),
            _SummaryItem(
                label: 'Consistency', value: '${weekly.consistencyScore}%'),
            _SummaryItem(label: 'Completed', value: '${weekly.totalCompleted}'),
            _SummaryItem(
                label: 'Full Cycle', value: '${weekly.fullCycleCompleted}'),
          ],
        ),
        const SizedBox(height: 16),
        _GoalProgressCard(goal: weekly.goalProgress),
        const SizedBox(height: 16),
        ...weekly.stageMetrics.map((metric) =>
            _StageCard(metric: metric, accent: const Color(0xFF1D4ED8))),
        if (dashboard.patterns.isNotEmpty) ...[
          const SizedBox(height: 16),
          _PatternInsightCard(patterns: dashboard.patterns),
        ],
      ],
    );
  }
}

class _MonthlyTab extends StatelessWidget {
  const _MonthlyTab();

  @override
  Widget build(BuildContext context) {
    final dashboard =
        context.select((AnalyticsBloc bloc) => bloc.state.dashboard)!;
    final monthly = dashboard.monthly;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Text(monthly.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _SummaryGrid(
          metrics: [
            _SummaryItem(label: 'Active Days', value: '${monthly.activeDays}'),
            _SummaryItem(
                label: 'Started', value: '${monthly.totalProblemsStarted}'),
            _SummaryItem(
                label: 'Completed', value: '${monthly.totalCompleted}'),
            _SummaryItem(
                label: 'Full Cycle', value: '${monthly.fullCycleCompleted}'),
          ],
        ),
        const SizedBox(height: 16),
        ...monthly.stageMetrics.map((metric) =>
            _StageCard(metric: metric, accent: const Color(0xFF7C3AED))),
        const SizedBox(height: 16),
        Text('Week By Week', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...monthly.weekBreakdown.map((week) => _MonthWeekCard(week: week)),
      ],
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard({required this.goal});

  final GoalProgress goal;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Goal Progress',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _ProgressRow(
              label: 'Problems',
              current: goal.actualProblems,
              target: goal.targetProblems,
              percent: goal.problemsProgress,
            ),
            const SizedBox(height: 12),
            _ProgressRow(
              label: 'Revisions',
              current: goal.actualRevisions,
              target: goal.targetRevisions,
              percent: goal.revisionsProgress,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.current,
    required this.target,
    required this.percent,
  });

  final String label;
  final int current;
  final int target;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress =
        target <= 0 ? 0.0 : (current / target).clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text('$current/$target'),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 6),
        Text('$percent% complete',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _PatternInsightCard extends StatelessWidget {
  const _PatternInsightCard({required this.patterns});

  final List<PatternInsight> patterns;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pattern Insights',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ...patterns.map(
              (pattern) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(pattern.pattern),
                    ),
                    Text('Solved ${pattern.solved}'),
                    const SizedBox(width: 12),
                    Text('${pattern.successRate}%'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthWeekCard extends StatelessWidget {
  const _MonthWeekCard({required this.week});

  final MonthlyWeekBreakdown week;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(week.label,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Text('${week.totalCompleted} done'),
              ],
            ),
            const SizedBox(height: 4),
            Text('${week.startDate} to ${week.endDate}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: week.stageMetrics
                  .map(
                    (metric) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text('${metric.shortLabel}: ${metric.completed}'),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.metric, required this.accent});

  final StageMetric metric;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: accent, width: 5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(metric.shortLabel,
                  style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(metric.title,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(metric.description,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _DataPill(label: 'Due', value: metric.due.toString()),
                  _DataPill(label: 'Done', value: metric.completed.toString()),
                  _DataPill(label: 'Overdue', value: metric.overdue.toString()),
                  _DataPill(label: 'Backlog', value: metric.backlog.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataPill extends StatelessWidget {
  const _DataPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.metrics});

  final List<_SummaryItem> metrics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: metrics
          .map(
            (metric) => SizedBox(
              width: (MediaQuery.of(context).size.width - 44) / 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(metric.label,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Text(metric.value,
                          style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SummaryItem {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;
}
