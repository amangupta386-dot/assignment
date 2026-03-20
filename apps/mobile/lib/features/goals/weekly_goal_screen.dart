import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/goal_bloc.dart';

class WeeklyGoalScreen extends StatefulWidget {
  const WeeklyGoalScreen({super.key});

  @override
  State<WeeklyGoalScreen> createState() => _WeeklyGoalScreenState();
}

class _WeeklyGoalScreenState extends State<WeeklyGoalScreen> {
  final _targetProblems = TextEditingController(text: '10');
  final _targetRevisions = TextEditingController(text: '12');
  final _patterns = TextEditingController(text: 'HashMap,Sliding Window');

  @override
  void dispose() {
    _targetProblems.dispose();
    _targetRevisions.dispose();
    _patterns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Goal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _targetProblems, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Problems')),
            const SizedBox(height: 8),
            TextField(controller: _targetRevisions, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Revisions')),
            const SizedBox(height: 8),
            TextField(controller: _patterns, decoration: const InputDecoration(labelText: 'Focus Patterns (comma-separated)')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final patterns = _patterns.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                context.read<GoalBloc>().add(
                      SaveGoal(
                        targetProblems: int.tryParse(_targetProblems.text) ?? 10,
                        targetRevisions: int.tryParse(_targetRevisions.text) ?? 12,
                        focusPatterns: patterns,
                      ),
                    );
              },
              child: const Text('Save Goal'),
            ),
            const SizedBox(height: 16),
            BlocBuilder<GoalBloc, GoalState>(
              builder: (context, state) {
                final goal = state.goal;
                if (state.isLoading && state.goal == null) return const CircularProgressIndicator();
                if (state.error != null) return Text(state.error!);
                if (goal == null) return const Text('No current weekly goal');
                return Text('Current: ${goal.targetProblems} problems, ${goal.targetRevisions} revisions');
              },
            )
          ],
        ),
      ),
    );
  }
}

