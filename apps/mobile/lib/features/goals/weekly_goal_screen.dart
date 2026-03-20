import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/weekly_goal_model.dart';
import 'bloc/goal_bloc.dart';

class WeeklyGoalScreen extends StatefulWidget {
  const WeeklyGoalScreen({super.key});

  @override
  State<WeeklyGoalScreen> createState() => _WeeklyGoalScreenState();
}

class _WeeklyGoalScreenState extends State<WeeklyGoalScreen> {
  final List<_GoalProblemRow> _rows = <_GoalProblemRow>[_GoalProblemRow()];
  String _lastSeedSignature = '';

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
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

  void _seedRows(WeeklyGoalModel goal) {
    if (goal.goalProblems.isEmpty) return;
    final signature = goal.goalProblems.map((e) => '${e.problemName}|${e.patternName}').join('||');
    if (signature == _lastSeedSignature) return;
    _lastSeedSignature = signature;

    for (final row in _rows) {
      row.dispose();
    }
    _rows
      ..clear()
      ..addAll(
        goal.goalProblems.map(
          (item) => _GoalProblemRow(problem: item.problemName, pattern: item.patternName),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Goal')),
      body: BlocBuilder<GoalBloc, GoalState>(
        builder: (context, state) {
          final goal = state.goal;
          if (goal != null) {
            _seedRows(goal);
          }
          if (state.isLoading && state.goal == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text('Weekly Problem Goals', style: Theme.of(context).textTheme.titleMedium),
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
                          if (goalProblems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Add at least one valid problem and pattern')),
                            );
                            return;
                          }

                          context.read<GoalBloc>().add(SaveGoal(goalProblems: goalProblems));
                        },
                  child: Text(state.isLoading ? 'Saving...' : 'Save Goal'),
                ),
                const SizedBox(height: 12),
                if (state.error != null) Text(state.error!),
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
