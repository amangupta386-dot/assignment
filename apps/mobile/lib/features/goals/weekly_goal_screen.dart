import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../models/weekly_goal_model.dart';
import 'bloc/goal_bloc.dart';

class WeeklyGoalScreen extends StatefulWidget {
  const WeeklyGoalScreen({super.key});

  @override
  State<WeeklyGoalScreen> createState() => _WeeklyGoalScreenState();
}

class _WeeklyGoalScreenState extends State<WeeklyGoalScreen> {
  static const int _maxGoalQuestions = 7;

  final List<_GoalProblemRow> _rows = <_GoalProblemRow>[_GoalProblemRow()];
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _appliedPlanningInsights = false;
  int _handledSaveVersion = 0;

  @override
  void initState() {
    super.initState();
    _resetFormState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalBloc>().add(LoadGoalPlanningInsights());
    });
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _fromDate = DateTime(picked.year, picked.month, picked.day);
      if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
        _toDate = _fromDate;
      }
    });
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? _fromDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _toDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  void _addRow() {
    if (_rows.length >= _maxGoalQuestions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can add up to 7 questions in one week'),
        ),
      );
      return;
    }
    setState(() {
      _rows.add(_GoalProblemRow());
    });
  }

  void _removeRow(int index) {
    if (_rows.length == 1) return;
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  void _resetFormState() {
    for (final row in _rows) {
      row.dispose();
    }
    _rows
      ..clear()
      ..add(_GoalProblemRow());
    _fromDate = null;
    _toDate = null;
  }

  void _applyPlanningInsights(WeeklyGoalPlanningInsights insights) {
    final parsedFrom = DateTime.tryParse(insights.fromDate);
    final parsedTo = DateTime.tryParse(insights.toDate);
    final recommended = insights.recommendedTarget.clamp(1, _maxGoalQuestions);
    final carryForward = insights.carryForwardProblems.take(_maxGoalQuestions);

    for (final row in _rows) {
      row.dispose();
    }

    _rows
      ..clear()
      ..addAll(
        carryForward.map(
          (item) => _GoalProblemRow(
            problem: item.problemName,
            pattern: item.patternName,
            timeComplexity: item.timeComplexity,
          ),
        ),
      );

    while (_rows.length < recommended) {
      _rows.add(_GoalProblemRow());
    }

    if (_rows.isEmpty) {
      _rows.add(_GoalProblemRow());
    }

    _fromDate = parsedFrom;
    _toDate = parsedTo;
    _appliedPlanningInsights = true;
  }

  List<GoalProblemItem> _collectGoalProblems() {
    return _rows
        .map(
          (row) => GoalProblemItem(
            problemName: row.problemController.text.trim(),
            patternName: row.patternController.text.trim(),
            timeComplexity: row.timeComplexityController.text.trim(),
          ),
        )
        .where((item) =>
            item.problemName.isNotEmpty &&
            item.patternName.isNotEmpty &&
            item.timeComplexity.isNotEmpty)
        .toList();
  }

  String _displayDate(DateTime? value) =>
      value == null ? 'Select date' : _dateFormat.format(value);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final validGoalCount = _collectGoalProblems().length;

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Goal')),
      body: SelectionArea(
        child: BlocConsumer<GoalBloc, GoalState>(
          listenWhen: (previous, current) =>
              previous.saveVersion != current.saveVersion ||
              previous.planningInsights != current.planningInsights,
          listener: (context, state) {
            if (state.planningInsights != null && !_appliedPlanningInsights) {
              setState(() {
                _applyPlanningInsights(state.planningInsights!);
              });
            }

            if (state.saveVersion > _handledSaveVersion) {
              _handledSaveVersion = state.saveVersion;
              _resetFormState();
              _appliedPlanningInsights = false;
              context.read<GoalBloc>().add(LoadGoalPlanningInsights());
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Goal timeline saved')),
              );
            }
          },
          builder: (context, state) {
            final planningInsights = state.planningInsights;
            final lastWeek = planningInsights?.lastWeek;

            return ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
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
                        'Plan The Upcoming Week',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set up to 7 problems for the next week. Your target is adapted from last week so the app keeps pushing you without building a bad backlog.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _GoalStatTile(
                              label: 'Added',
                              value: '$validGoalCount',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GoalStatTile(
                              label: 'Target',
                              value:
                                  '${planningInsights?.recommendedTarget ?? 0}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GoalStatTile(
                              label: 'Carry',
                              value:
                                  '${planningInsights?.carryForwardProblems.length ?? 0}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (planningInsights != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Target Recommendation',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Recommended total target: ${planningInsights.recommendedTarget}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Suggested fresh problems to add: ${planningInsights.suggestedNewProblems}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (lastWeek != null &&
                              lastWeek.plannedCount > 0) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Last Week Performance',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${lastWeek.completedDayOneCount}/${lastWeek.plannedCount} Day 1 completions',
                                  ),
                                  Text(
                                    'Completion rate: ${lastWeek.completionRate}%',
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
                  ),
                ],
                if (planningInsights != null &&
                    planningInsights.carryForwardProblems.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Carry Forward Problems',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  ...planningInsights.carryForwardProblems.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
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
                          const SizedBox(height: 6),
                          Text(
                            '${item.patternName} • ${item.timeComplexity}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Planning Window',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickFromDate,
                                icon: const Icon(Icons.calendar_month_outlined),
                                label: Text(_displayDate(_fromDate)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickToDate,
                                icon:
                                    const Icon(Icons.event_available_outlined),
                                label: Text(_displayDate(_toDate)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Problems For Next Week',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('$validGoalCount / $_maxGoalQuestions'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...List<Widget>.generate(_rows.length, (index) {
                  final row = _rows[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Question ${index + 1}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const Spacer(),
                              if (_rows.length > 1)
                                TextButton.icon(
                                  onPressed: () => _removeRow(index),
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Remove'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: row.problemController,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Problem Name',
                              prefixIcon: Icon(Icons.code_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: row.patternController,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Pattern Name',
                              prefixIcon: Icon(Icons.hub_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: row.timeComplexityController,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Optimized Time Complexity',
                              prefixIcon: Icon(Icons.timer_outlined),
                              hintText: 'Example: O(n) or O(log n)',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                OutlinedButton.icon(
                  onPressed: _addRow,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Another Question'),
                ),
                const SizedBox(height: 14),
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.only(bottom: 16),
                  child: FilledButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            final goalProblems = _collectGoalProblems();
                            if (_fromDate == null || _toDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Please select from and to dates'),
                                ),
                              );
                              return;
                            }
                            if (_toDate!.isBefore(_fromDate!)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('To date must be after from date'),
                                ),
                              );
                              return;
                            }
                            if (goalProblems.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Add at least one valid problem, pattern, and time complexity'),
                                ),
                              );
                              return;
                            }
                            if (goalProblems.length > _maxGoalQuestions) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'You can save up to 7 questions only'),
                                ),
                              );
                              return;
                            }

                            context.read<GoalBloc>().add(
                                  SaveGoal(
                                    fromDate: _fromDate!,
                                    toDate: _toDate!,
                                    goalProblems: goalProblems,
                                  ),
                                );
                          },
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      state.isLoading ? 'Saving...' : 'Save Goal Timeline',
                    ),
                  ),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    state.error!,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GoalProblemRow {
  _GoalProblemRow({
    String problem = '',
    String pattern = '',
    String timeComplexity = 'O(n)',
  })  : problemController = TextEditingController(text: problem),
        patternController = TextEditingController(text: pattern),
        timeComplexityController = TextEditingController(text: timeComplexity);

  final TextEditingController problemController;
  final TextEditingController patternController;
  final TextEditingController timeComplexityController;

  void dispose() {
    problemController.dispose();
    patternController.dispose();
    timeComplexityController.dispose();
  }
}

class _GoalStatTile extends StatelessWidget {
  const _GoalStatTile({
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
