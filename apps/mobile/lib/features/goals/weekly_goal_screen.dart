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

  @override
  void initState() {
    super.initState();
    _resetFormState();
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

  List<GoalProblemItem> _collectGoalProblems() {
    return _rows
        .map(
          (row) => GoalProblemItem(
            problemName: row.problemController.text.trim(),
            patternName: row.patternController.text.trim(),
          ),
        )
        .where((item) =>
            item.problemName.isNotEmpty && item.patternName.isNotEmpty)
        .toList();
  }

  String _displayDate(DateTime? value) =>
      value == null ? 'Select date' : _dateFormat.format(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Goal')),
      body: BlocConsumer<GoalBloc, GoalState>(
        listenWhen: (previous, current) =>
            previous.saveVersion != current.saveVersion,
        listener: (context, state) {
          _resetFormState();
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Goal timeline saved')),
          );
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text('Weekly Timeline',
                    style: Theme.of(context).textTheme.titleMedium),
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
                Text('Problems For Timeline',
                    style: Theme.of(context).textTheme.titleMedium),
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
                            decoration: const InputDecoration(
                                labelText: 'Problem Name'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: row.patternController,
                            decoration: const InputDecoration(
                                labelText: 'Pattern Name'),
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
                              const SnackBar(
                                  content:
                                      Text('Please select from and to dates')),
                            );
                            return;
                          }
                          if (_toDate!.isBefore(_fromDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('To date must be after from date')),
                            );
                            return;
                          }
                          if (goalProblems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Add at least one valid problem and pattern')),
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
                  child: Text(
                      state.isLoading ? 'Saving...' : 'Save Goal Timeline'),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 16),
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
