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
  final List<_GoalProblemRow> _rows = <_GoalProblemRow>[_GoalProblemRow()];
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  DateTime? _fromDate;
  DateTime? _toDate;
  String _lastSeedSignature = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<GoalBloc>();
      bloc.add(LoadCurrentGoal());
      bloc.add(LoadMonthlyTimeline(month: DateTime.now()));
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

  List<GoalProblemItem> _collectGoalProblems() {
    return _rows
        .map(
          (row) => GoalProblemItem(
            problemName: row.problemController.text.trim(),
            patternName: row.patternController.text.trim(),
          ),
        )
        .where((item) => item.problemName.isNotEmpty && item.patternName.isNotEmpty)
        .toList();
  }

  void _seedFromGoal(WeeklyGoalModel goal) {
    final signature = '${goal.fromDate}|${goal.toDate}|${goal.goalProblems.map((e) => '${e.problemName}|${e.patternName}').join('||')}';
    if (signature == _lastSeedSignature) return;
    _lastSeedSignature = signature;

    final parsedFrom = DateTime.tryParse(goal.fromDate);
    final parsedTo = DateTime.tryParse(goal.toDate);
    if (parsedFrom != null) _fromDate = parsedFrom;
    if (parsedTo != null) _toDate = parsedTo;

    if (goal.goalProblems.isNotEmpty) {
      for (final row in _rows) {
        row.dispose();
      }
      _rows
        ..clear()
        ..addAll(
          goal.goalProblems.map((item) => _GoalProblemRow(problem: item.problemName, pattern: item.patternName)),
        );
    }
  }

  String _displayDate(DateTime? value) => value == null ? 'Select date' : _dateFormat.format(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Goal')),
      body: BlocBuilder<GoalBloc, GoalState>(
        builder: (context, state) {
          final goal = state.goal;
          if (goal != null) {
            _seedFromGoal(goal);
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text('Weekly Timeline', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pickFromDate,
                        child: Text('From: ${_displayDate(_fromDate)}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pickToDate,
                        child: Text('To: ${_displayDate(_toDate)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Problems For Timeline', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...List<Widget>.generate(_rows.length, (index) {
                  final row = _rows[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextField(
                            controller: row.problemController,
                            decoration: const InputDecoration(labelText: 'Problem Name'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: row.patternController,
                            decoration: const InputDecoration(labelText: 'Pattern Name'),
                          ),
                          if (_rows.length > 1)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _removeRow(index),
                                child: const Text('Remove'),
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
                  label: const Text('Add Problem'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          final goalProblems = _collectGoalProblems();
                          if (_fromDate == null || _toDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select from and to dates')),
                            );
                            return;
                          }
                          if (_toDate!.isBefore(_fromDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('To date must be after from date')),
                            );
                            return;
                          }
                          if (goalProblems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Add at least one valid problem and pattern')),
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
                  child: Text(state.isLoading ? 'Saving...' : 'Save Goal Timeline'),
                ),
                const SizedBox(height: 16),
                Text('Monthly Timeline', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (state.timelines.isEmpty)
                  const Text('No timeline entries for this month')
                else
                  ...state.timelines.map(
                    (entry) => Card(
                      child: ListTile(
                        title: Text('${entry.fromDate} to ${entry.toDate}'),
                        subtitle: Text('${entry.goalProblems.length} problems'),
                      ),
                    ),
                  ),
                if (state.error != null) ...[
                  const SizedBox(height: 12),
                  Text(state.error!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GoalProblemRow {
  _GoalProblemRow({String problem = '', String pattern = ''})
      : problemController = TextEditingController(text: problem),
        patternController = TextEditingController(text: pattern);

  final TextEditingController problemController;
  final TextEditingController patternController;

  void dispose() {
    problemController.dispose();
    patternController.dispose();
  }
}
