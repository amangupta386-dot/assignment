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
  static const int _maxGoalQuestions = 15;

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
    if (_rows.length >= _maxGoalQuestions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can add up to 15 questions in one week'),
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
    final colorScheme = Theme.of(context).colorScheme;
    final validGoalCount = _collectGoalProblems().length;

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Goal')),
      body: SelectionArea(
        child: BlocConsumer<GoalBloc, GoalState>(
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
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                        'Plan Your Week',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add 10 to 15 questions for the week so Today Plan can show the assigned question and extra questions when you have more time.',
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
                          const Expanded(
                            child: _GoalStatTile(
                              label: 'Limit',
                              value: '15',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GoalStatTile(
                              label: 'Rows',
                              value: '${_rows.length}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Timeline',
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
                        'Questions For This Week',
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
                FilledButton.icon(
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
                                    'Add at least one valid problem and pattern'),
                              ),
                            );
                            return;
                          }
                          if (goalProblems.length > _maxGoalQuestions) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'You can save up to 15 questions only'),
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
