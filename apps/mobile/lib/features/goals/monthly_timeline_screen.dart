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
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Timeline')),
      body: BlocBuilder<GoalBloc, GoalState>(
        builder: (context, state) {
          final timelines = List<WeeklyGoalModel>.from(state.timelines)
            ..sort((a, b) => a.fromDate.compareTo(b.fromDate));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _changeMonth(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      _monthFormat.format(_selectedMonth),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (state.error != null)
                Text(state.error!)
              else if (timelines.isEmpty)
                const Text('No timeline entries for this month')
              else
                ...List<Widget>.generate(timelines.length, (index) {
                  final entry = timelines[index];
                  return _WeekTimelineCard(
                    weekLabel: 'Week ${index + 1}',
                    entry: entry,
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _WeekTimelineCard extends StatelessWidget {
  const _WeekTimelineCard({
    required this.weekLabel,
    required this.entry,
  });

  final String weekLabel;
  final WeeklyGoalModel entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(weekLabel, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${entry.fromDate} to ${entry.toDate}'),
            const SizedBox(height: 12),
            if (entry.goalProblems.isEmpty)
              const Text('No problems added')
            else
              ...entry.goalProblems.map(
                (problem) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.circle, size: 8),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(problem.problemName),
                            const SizedBox(height: 6),
                            ActionChip(
                              avatar: const Icon(
                                Icons.hub_outlined,
                                size: 16,
                              ),
                              label: Text(problem.patternName),
                              onPressed: () => openPatternNoteOrShowSnackbar(
                                context,
                                problem.patternName,
                              ),
                            ),
                          ],
                        ),
                      ),
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
