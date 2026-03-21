import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../models/weekly_goal_model.dart';
import '../pattern_notes/pattern_note_link.dart';
import 'bloc/goal_bloc.dart';

class MonthlyTimelineScreen extends StatefulWidget {
  const MonthlyTimelineScreen({super.key});

  @override
  State<MonthlyTimelineScreen> createState() => _MonthlyTimelineScreenState();
}

class _MonthlyTimelineScreenState extends State<MonthlyTimelineScreen> {
  final DateFormat _monthFormat = DateFormat('MMMM yyyy');
  final DateFormat _dayFormat = DateFormat('dd MMM');
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalBloc>().add(LoadMonthlyTimeline(month: _selectedMonth));
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + offset);
    });
    context.read<GoalBloc>().add(LoadMonthlyTimeline(month: _selectedMonth));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Timeline')),
      body: SelectionArea(
        child: BlocBuilder<GoalBloc, GoalState>(
          builder: (context, state) {
            final timelines = List<WeeklyGoalModel>.from(state.timelines)
              ..sort((a, b) => a.fromDate.compareTo(b.fromDate));
            final totalProblems = timelines.fold<int>(
              0,
              (sum, item) => sum + item.goalProblems.length,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF164E63)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Roadmap',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track every planned week for this month, review problem load, and jump into pattern notes directly from the timeline.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _HeaderMetric(
                              label: 'Weeks',
                              value: '${timelines.length}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _HeaderMetric(
                              label: 'Problems',
                              value: '$totalProblems',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _HeaderMetric(
                              label: 'Month',
                              value: DateFormat('MMM').format(_selectedMonth),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      _MonthNavButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => _changeMonth(-1),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _monthFormat.format(_selectedMonth),
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Weekly goals and carry-forward view',
                              textAlign: TextAlign.center,
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
                      _MonthNavButton(
                        icon: Icons.chevron_right_rounded,
                        onTap: () => _changeMonth(1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.error != null)
                  _TimelineMessageCard(
                    icon: Icons.error_outline,
                    title: 'Unable to load timeline',
                    message: state.error!,
                  )
                else if (timelines.isEmpty)
                  const _TimelineMessageCard(
                    icon: Icons.event_note_outlined,
                    title: 'No timeline yet',
                    message:
                        'Save a weekly goal for this month to start building your roadmap.',
                  )
                else ...[
                  Text(
                    'Weeks In Focus',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...List<Widget>.generate(timelines.length, (index) {
                    final entry = timelines[index];
                    final isLast = index == timelines.length - 1;
                    return _WeekTimelineCard(
                      weekLabel: 'Week ${index + 1}',
                      entry: entry,
                      isLast: isLast,
                      dayFormat: _dayFormat,
                    );
                  }),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WeekTimelineCard extends StatelessWidget {
  const _WeekTimelineCard({
    required this.weekLabel,
    required this.entry,
    required this.isLast,
    required this.dayFormat,
  });

  final String weekLabel;
  final WeeklyGoalModel entry;
  final bool isLast;
  final DateFormat dayFormat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final startDate = DateTime.tryParse(entry.fromDate);
    final endDate = DateTime.tryParse(entry.toDate);
    final dateLabel = startDate != null && endDate != null
        ? '${dayFormat.format(startDate)} - ${dayFormat.format(endDate)}'
        : '${entry.fromDate} - ${entry.toDate}';

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primaryContainer,
                    width: 3,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 160,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: colorScheme.outlineVariant,
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          weekLabel,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${entry.goalProblems.length} problems',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dateLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Planned questions and their core pattern references for this week.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (entry.goalProblems.isEmpty)
                    Text(
                      'No problems added for this week.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    )
                  else
                    ...entry.goalProblems.asMap().entries.map((item) {
                      return _ProblemTimelineTile(
                        index: item.key + 1,
                        problem: item.value,
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProblemTimelineTile extends StatelessWidget {
  const _ProblemTimelineTile({
    required this.index,
    required this.problem,
  });

  final int index;
  final GoalProblemItem problem;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$index',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  problem.problemName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ActionChip(
                avatar: const Icon(Icons.hub_outlined, size: 16),
                label: Text(problem.patternName),
                onPressed: () =>
                    openPatternNoteOrShowSnackbar(context, problem.patternName),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      problem.timeComplexity,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  const _MonthNavButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _TimelineMessageCard extends StatelessWidget {
  const _TimelineMessageCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}
