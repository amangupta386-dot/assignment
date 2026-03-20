import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/problem_bloc.dart';

class AddProblemScreen extends StatefulWidget {
  const AddProblemScreen({super.key});

  @override
  State<AddProblemScreen> createState() => _AddProblemScreenState();
}

class _AddProblemScreenState extends State<AddProblemScreen> {
  final _titleController = TextEditingController();
  String _platform = 'LEETCODE';
  String _difficulty = 'EASY';
  String _status = 'SOLVED';
  final _patternController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _patternController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Problem')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: _patternController, decoration: const InputDecoration(labelText: 'Pattern')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _platform,
              items: const ['LEETCODE', 'GFG', 'CODESTUDIO', 'OTHER']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _platform = v ?? 'LEETCODE'),
              decoration: const InputDecoration(labelText: 'Platform'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _difficulty,
              items: const ['EASY', 'MEDIUM', 'HARD']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _difficulty = v ?? 'EASY'),
              decoration: const InputDecoration(labelText: 'Difficulty'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _status,
              items: const ['SOLVED', 'WITH_HELP', 'NOT_SOLVED']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? 'SOLVED'),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 16),
            BlocConsumer<ProblemBloc, ProblemState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
                } else if (!state.isLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Problem added')),
                  );
                }
              },
              builder: (context, state) {
                return FilledButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          context.read<ProblemBloc>().add(
                                AddProblem(
                                  title: _titleController.text.trim(),
                                  platform: _platform,
                                  difficulty: _difficulty,
                                  pattern: _patternController.text.trim(),
                                  initialStatus: _status,
                                ),
                              );
                        },
                  child: Text(state.isLoading ? 'Saving...' : 'Save'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
